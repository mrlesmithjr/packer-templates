#! /usr/bin/env python
"""Just a small little script to help manage Packer templates in this repo."""

import argparse
from datetime import datetime
import json
import logging
import os
import shutil
import time
import requests
import git

__author__ = "Larry Smith Jr."
__email__ = "mrlesmithjr@gmail.com"
__maintainer__ = "Larry Smith Jr."
__status__ = "Development"
# http://everythingshouldbevirtual.com
# @mrlesmithjr

logging.basicConfig(level=logging.INFO)

API_URL = 'https://app.vagrantup.com/api/v1/'
BUILD_OLDER_THAN_DAYS = 30
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))


def main():
    """Main program execution."""
    args = parse_args()
    decide_action(args)


def parse_args():
    """Parse CLI arguments."""
    parser = argparse.ArgumentParser(description="Packer template utils.")
    parser.add_argument(
        "action", help="Define action to take.", choices=[
            'build_all', 'change_controller', 'cleanup_builds',
            'commit_manifests', 'get_boxes', 'rename_templates',
            'repo_info', 'upload_boxes', 'view_manifests'])
    parser.add_argument('--controller',
                        help='Define hard drive controller type',
                        choices=['ide', 'sata', 'scsi'])
    args = parser.parse_args()
    if args.action == 'change_controller' and args.controller is None:
        parser.error('--controller is REQUIRED!')
    return args


def decide_action(args):
    """Make decision on what to do from arguments being passed."""
    if args.action == 'build_all':
        build_all()
        # upload_boxes()
    elif args.action == 'change_controller':
        change_controller(args)
    elif args.action == 'cleanup_builds':
        cleanup_builds()
    elif args.action == 'commit_manifests':
        repo_facts = dict()
        repo_info(repo_facts)
        commit_manifests(repo_facts)
    elif args.action == 'get_boxes':
        boxes = dict()
        get_boxes(boxes)
        print json.dumps(boxes, indent=4)
    elif args.action == 'rename_templates':
        rename_templates()
    elif args.action == 'repo_info':
        repo_facts = dict()
        repo_info(repo_facts)
        print json.dumps(repo_facts, indent=4)
    elif args.action == 'upload_boxes':
        upload_boxes()
    elif args.action == 'view_manifests':
        view_manifests()


def get_boxes(boxes):
    """Connect to Vagrant Cloud API and get boxes."""
    private_vars_file = os.path.join(SCRIPT_DIR, 'private_vars.json')
    box_api_url = API_URL + 'box/'
    if os.path.isfile(private_vars_file):
        with open(private_vars_file) as priv_vars:
            priv_data = json.load(priv_vars)
            try:
                vagrant_cloud_token = priv_data['vagrant_cloud_token']
                for root, dirs, files in os.walk(SCRIPT_DIR):
                    if 'box_info.json' in files:
                        with open(os.path.join(root, 'box_info.json'),
                                  'r') as box_info:
                            data = json.load(box_info)
                            box_tag = data['box_tag']
                            url = '{0}{1}'.format(box_api_url, box_tag)
                            headers = {'Authorization': 'Bearer {0}'.format(
                                vagrant_cloud_token)}
                            response = requests.get(url, headers=headers)
                            if response.status_code == 200:
                                json_data = response.json()
                                boxes[json_data['tag']] = json_data
            except KeyError:
                print 'Vagrant Cloud token missing...'
    else:
        print 'private_vars.json missing...'


def repo_info(repo_facts):
    """Collect important repo info and store as facts."""
    changed_files = []
    repo_remotes = []
    repo_path = os.getcwd()
    repo = git.Repo(repo_path)
    for item in repo.index.diff(None):
        changed_files.append(item.a_path)
    for item in repo.remotes:
        remote_info = dict()
        remote_info[item.name] = {"url": item.url}
        repo_remotes.append(remote_info)
    repo_facts['changed_files'] = changed_files
    repo_facts['remotes'] = repo_remotes
    repo_facts['untracked_files'] = repo.untracked_files


def build_all():
    """Looks for build script in each directory and then executes it."""
    print 'Building all images.'
    for root, dirs, files in os.walk(SCRIPT_DIR):
        if 'build.sh' in files:
            with open(os.path.join(root, 'box_info.json'),
                      'r') as box_info_file:
                box_info = json.load(box_info_file)
                try:
                    auto_build = box_info['auto_build']
                    if auto_build.lower() == 'true':
                        auto_build = True
                    else:
                        auto_build = False
                except KeyError:
                    auto_build = True
                build_image = get_box(box_info)
                if auto_build and build_image:
                    print 'Executing build.sh in {0}'.format(root)
                    os.chdir(root)
                    os.system('./{0}'.format('build.sh'))
                    os.chdir(SCRIPT_DIR)


def get_box(box_info):
    """Attempt to read box from Vagrant Cloud API."""
    build_image = False
    private_vars_file = os.path.join(SCRIPT_DIR, 'private_vars.json')
    box_api_url = API_URL + 'box'
    if os.path.isfile(private_vars_file):
        with open(private_vars_file) as priv_vars:
            priv_data = json.load(priv_vars)
            try:
                username = priv_data['username']
                vagrant_cloud_token = priv_data['vagrant_cloud_token']
                url = '{0}/{1}/{2}'.format(box_api_url,
                                           username, box_info['box_name'])
                headers = {'Authorization': 'Bearer {0}'.format(
                    vagrant_cloud_token)}
                response = requests.get(url, headers=headers)
                json_data = response.json()
                if response.status_code == 200:
                    update_box(priv_data, box_info)
                    current_time = datetime.now()
                    current_version = json_data['current_version']
                    if current_version is not None:
                        last_updated_str = json_data['current_version'][
                            'updated_at']
                        last_updated_object = datetime.strptime(
                            last_updated_str, '%Y-%m-%dT%H:%M:%S.%fZ')
                        since_updated_days = (
                            current_time - last_updated_object).days
                        if since_updated_days > BUILD_OLDER_THAN_DAYS:
                            build_image = True
                    else:
                        build_image = True
                elif response.status_code == 404:
                    print 'Box missing'
                    create_box(priv_data, box_info)
                    build_image = True
                else:
                    print response.status_code
            except KeyError:
                print 'Vagrant Cloud token missing...'
    else:
        print 'private_vars.json missing...'
    return build_image


def create_box(priv_data, box_info):
    """Create box if missing using Vagrant Cloud API."""
    boxes_api_url = API_URL + 'boxes'
    username = priv_data['username']
    vagrant_cloud_token = priv_data['vagrant_cloud_token']
    url = '{0}/'.format(boxes_api_url)
    headers = {'Content-Type': 'application/json',
               'Authorization': 'Bearer {0}'.format(vagrant_cloud_token)}
    payload = {
        'box':
        {
            'username': username,
            'name': box_info['box_name'],
            'is_private': box_info['private'],
            'short_description': box_info['short_description'],
            'description': box_info['description']}
    }
    response = requests.post(url, headers=headers, data=json.dumps(payload))
    json_response = response.json()
    if response.status_code == 200:
        pass
    else:
        print response.status_code
    print json_response


def update_box(priv_data, box_info):
    """Update box info using Vagrant Cloud API."""
    box_api_url = API_URL + 'box'
    username = priv_data['username']
    vagrant_cloud_token = priv_data['vagrant_cloud_token']
    url = '{0}/{1}/{2}'.format(box_api_url,
                               username, box_info['box_name'])
    headers = {'Content-Type': 'application/json',
               'Authorization': 'Bearer {0}'.format(vagrant_cloud_token)}
    payload = {
        'box':
        {
            'name': box_info['box_name'],
            'is_private': box_info['private'],
            'short_description': box_info['short_description'],
            'description': box_info['description']}
    }
    print 'Updating box: {0}/{1} info.'.format(username, box_info['box_name'])
    response = requests.put(url, headers=headers, data=json.dumps(payload))
    json_response = response.json()
    if response.status_code == 200:
        pass
    else:
        print response.status_code
        print json_response


def change_controller(args):
    """Change hard drive controller type for all templates."""
    controller_type = args.controller
    for root, dirs, files in os.walk(SCRIPT_DIR):
        for index, item in enumerate(files):
            filename, ext = os.path.splitext(item)
            if ext == '.json':
                try:
                    json_file = os.path.join(root, item)
                    with open(json_file, 'r') as stream:
                        data = json.load(stream)
                        try:
                            controller = data['variables'][
                                'vm_disk_adapter_type']
                            if controller != controller_type:
                                with open(json_file, 'r') as json_file_data:
                                    read_data = json_file_data.read()
                                    read_data = read_data.replace(
                                        controller, controller_type)
                                with open(json_file, 'w') as (json_file_data):
                                    json_file_data.write(read_data)
                        except KeyError:
                            pass
                except TypeError:
                    pass


def cleanup_builds():
    """Clean up lingering build data and artifacts."""
    print 'Cleaning up any lingering build data.'
    for root, dirs, files in os.walk(SCRIPT_DIR):
        for item in dirs:
            if 'output-' in item:
                shutil.rmtree(os.path.join(root, item))
            if item == '.vagrant':
                shutil.rmtree(os.path.join(root, item))
            if item == 'packer_cache':
                shutil.rmtree(os.path.join(root, item))

        for item in files:
            filename, ext = os.path.splitext(item)
            if filename == 'Vagrantfile':
                os.remove(os.path.join(root, item))
            if ext == '.box':
                os.remove(os.path.join(root, item))
            if ext == '.iso':
                os.remove(os.path.join(root, item))


def rename_templates():
    """Renames legacy template names to more standardized template.json."""
    print 'Renaming templates to follow standard naming.'
    for root, dirs, files in os.walk(SCRIPT_DIR):
        for index, item in enumerate(files):
            filename, ext = os.path.splitext(item)
            if ext == '.json':
                try:
                    json_file = os.path.join(root, item)
                    with open(json_file, 'r') as stream:
                        data = json.load(stream)
                        try:
                            vm_name = data['vm_name']
                            json_template = os.path.join(root, 'template.json')
                            build_script = os.path.join(root, 'build.sh')
                            with open(build_script, 'r') as build_script_data:
                                read_data = build_script_data.read()
                                read_data = read_data.replace(
                                    item, 'template.json')
                            with open(build_script, 'w') as (
                                    build_script_data):
                                build_script_data.write(read_data)
                            os.system('git add {0}'.format(build_script))
                            if item != 'template.json':
                                os.system('git mv {0} {1}'.format(
                                    json_file, json_template))
                        except KeyError:
                            pass
                except TypeError:
                    pass


def upload_boxes():
    """Looks for upload_boxes script in each directory and then executes it."""
    print 'Uploading all images.'
    for root, dirs, files in os.walk(SCRIPT_DIR):
        if root != SCRIPT_DIR:
            if 'upload_boxes.sh' in files:
                print 'Executing upload_boxes.sh in {0}'.format(root)
                os.chdir(root)
                os.system('./{0}'.format('upload_boxes.sh'))


def commit_manifests(repo_facts):
    repo_path = os.getcwd()
    repo = git.Repo(repo_path)
    commit = False
    for item in repo_facts['changed_files']:
        if 'manifest.json' in item:
            repo.index.add([item])
            commit = True
    for item in repo_facts['untracked_files']:
        if 'manifest.json' in item:
            repo.index.add([item])
            commit = True
    if commit:
        commit_date = datetime.now().strftime('%Y-%m-%d-%H-%M-%S')
        commit_msg = '{} - Manifest Updates'.format(commit_date)
        repo.git.commit('-m', '{}'.format(commit_msg))
        repo.git.push()


def view_manifests():
    for root, dirs, files in os.walk(SCRIPT_DIR):
        if 'manifest.json' in files:
            json_file = os.path.join(root, 'manifest.json')
            with open(json_file, 'r') as stream:
                data = json.load(stream)
                print json.dumps(data, indent=4)


# def latest_build(root):
#     build_image = False
#     current_time_epoch = time.mktime(datetime.now().timetuple())
#     older_than_days_epoch = current_time_epoch - \
#         (86400 * BUILD_OLDER_THAN_DAYS)
#     older_than_days = int((older_than_days_epoch/86400) + 25569)
#     json_file = os.path.join(root, 'manifest.json')
#     if os.path.isfile(json_file):
#         with open(json_file, 'r') as stream:
#             data = json.load(stream)
#             last_run_uuid = data['last_run_uuid']
#             builds = data['builds']
#             for build in builds:
#                 if build['packer_run_uuid'] == last_run_uuid:
#                     last_build_time_epoch = build['build_time']
#                     last_build_time = int(
#                         (last_build_time_epoch/86400) + 25569)
#                     if last_build_time < older_than_days:
#                         build_image = True
#                     break
#     else:
#         build_image = True
#     return build_image


if __name__ == '__main__':
    main()
