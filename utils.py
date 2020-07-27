#! /usr/bin/env python
"""Just a small little script to help manage Packer templates in this repo."""

import argparse
from datetime import datetime, timezone
import json
import logging
import os
import re
import shutil
import time
import subprocess
import sys
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
    username, vagrant_cloud_token = private_vars()
    decide_action(args, username, vagrant_cloud_token)


def private_vars():
    private_vars_file = os.path.join(SCRIPT_DIR, 'private_vars.json')
    if os.path.isfile(private_vars_file):
        with open(private_vars_file) as priv_vars:
            priv_data = json.load(priv_vars)
            username = priv_data.get('vagrant_cloud_username')
            vagrant_cloud_token = priv_data.get('vagrant_cloud_token')
            if username is not None and vagrant_cloud_token is not None:
                pass
            else:
                print('Vagrant Cloud token/username missing...')
    else:
        print('private_vars.json missing...')
        sys.exit(1)

    return username, vagrant_cloud_token


def parse_args():
    """Parse CLI arguments."""
    parser = argparse.ArgumentParser(description="Packer template utils.")
    parser.add_argument(
        "action", help="Define action to take.", choices=[
            'build_all', 'change_controller', 'cleanup_builds',
            'commit_manifests', 'get_boxes', 'prep_builds', 'rename_templates',
            'repo_info', 'upload_boxes', 'view_last_build_times',
            'view_manifests'])
    parser.add_argument('--controller',
                        help='Define hard drive controller type',
                        choices=['ide', 'sata', 'scsi'])
    args = parser.parse_args()
    if args.action == 'change_controller' and args.controller is None:
        parser.error('--controller is REQUIRED!')
    return args


def decide_action(args, username, vagrant_cloud_token):
    """Make decision on what to do from arguments being passed."""
    if args.action == 'build_all':
        build_all(username, vagrant_cloud_token)
        # upload_boxes(username, vagrant_cloud_token)
    elif args.action == 'change_controller':
        change_controller(args)
    elif args.action == 'cleanup_builds':
        cleanup_builds()
    elif args.action == 'commit_manifests':
        repo, repo_facts = repo_info()
        commit_manifests(repo_facts)
    elif args.action == 'get_boxes':
        boxes = dict()
        get_boxes(boxes, vagrant_cloud_token)
        print(json.dumps(boxes, indent=4))
    elif args.action == 'prep_builds':
        repo, repo_facts = repo_info()
        builds = parse_folders()
        prep_builds(repo, repo_facts, builds)
    elif args.action == 'rename_templates':
        rename_templates()
    elif args.action == 'repo_info':
        repo, repo_facts = repo_info()
        print(json.dumps(repo_facts, indent=4))
    elif args.action == 'upload_boxes':
        upload_boxes(username, vagrant_cloud_token)
    elif args.action == 'view_last_build_times':
        view_last_build_times()
    elif args.action == 'view_manifests':
        view_manifests()


def parse_folders():
    """Parse folders to find environment.yml"""
    builds = list()
    for root, _dirs, files in os.walk(SCRIPT_DIR):
        if 'build.sh' in files:
            builds.append(root)
    return builds


def prep_builds(repo, repo_facts, builds):
    for build_dir in builds:
        cleanup_linked_dirs(build_dir, repo, repo_facts)
        cleanup_linked_files(build_dir, repo, repo_facts)


def cleanup_linked_dirs(build_dir, repo, repo_facts):
    linked_dirs = ['http', 'packer_cache', 'scripts']

    for linked_dir in linked_dirs:
        dir_path = os.path.join(build_dir, linked_dir)
        entry = f'{build_dir}/{linked_dir}'.replace(
            f'{SCRIPT_DIR}/', '')
        if os.path.exists(dir_path):
            if not os.path.islink(dir_path):
                entry_regex = re.compile(f'.*{entry}.*')
                if any(entry_regex.match(line) for line
                       in repo_facts['entries']):
                    repo.index.remove(entry, r=True)
                    if os.path.isdir(entry):
                        shutil.rmtree(entry)
                    os.symlink(os.path.join('..', '..', '..', linked_dir),
                               dir_path)
                    repo.index.add(entry)
                else:
                    if os.path.isdir(entry):
                        shutil.rmtree(entry)
                        os.symlink(os.path.join('..', '..', '..', linked_dir),
                                   dir_path)
                        repo.index.add(entry)

        else:
            os.symlink(os.path.join('..', '..', '..', linked_dir),
                       dir_path)
            repo.index.add(entry)


def cleanup_linked_files(build_dir, repo, repo_facts):
    """Cleanup linked files."""

    # Defines files that should be linked in environment directory
    linked_files = ['upload_boxes.sh']

    for linked_file in linked_files:
        file_path = os.path.join(build_dir, linked_file)
        if os.path.exists(file_path):
            if not os.path.islink(file_path):
                entry = f'{build_dir}/{linked_file}'.replace(
                    f'{SCRIPT_DIR}/', '')
                if entry in repo_facts['entries']:
                    repo.index.remove(entry)
                    os.remove(entry)
                if os.path.isfile(file_path):
                    os.remove(file_path)
                os.symlink(os.path.join(
                    '..', '..', '..', linked_file), file_path)
                repo.index.add(entry)
        else:
            os.symlink(os.path.join(
                '..', '..', '..', linked_file), file_path)
            repo.index.add(entry)


def get_boxes(boxes, vagrant_cloud_token):
    """Connect to Vagrant Cloud API and get boxes."""
    box_api_url = API_URL + 'box/'
    for root, _dirs, files in os.walk(SCRIPT_DIR):
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


def repo_info():
    """Collect important repo info and store as facts."""
    changed_files = list()
    entries = list()
    repo_remotes = list()
    repo_path = os.getcwd()
    repo = git.Repo(repo_path)
    for (path, _stage), _entry in repo.index.entries.items():
        entries.append(path)
    for item in repo.index.diff(None):
        changed_files.append(item.a_path)
    for item in repo.remotes:
        remote_info = dict()
        remote_info[item.name] = dict(url=item.url)
        repo_remotes.append(remote_info)
    repo_facts = dict(
        changed_files=changed_files,
        entries=entries,
        remotes=repo_remotes,
        untracked_files=repo.untracked_files,
        working_tree_dir=repo.working_tree_dir
    )
    return repo, repo_facts


def build_all(username, vagrant_cloud_token):
    """Looks for build script in each directory and then executes it."""
    print('Building all images.')
    for root, _dirs, files in os.walk(SCRIPT_DIR):
        if 'build.sh' in files:
            with open(os.path.join(root, 'box_info.json'),
                      'r') as box_info_file:
                box_info = json.load(box_info_file)
                auto_build = box_info['auto_build']
                if auto_build is not None:
                    if auto_build.lower() == 'true':
                        auto_build = True
                    else:
                        auto_build = False
                else:
                    auto_build = True
                build_image = get_box(box_info, username, vagrant_cloud_token)
                if auto_build and build_image:
                    print('Executing build.sh in {0}'.format(root))
                    os.chdir(root)
                    process = subprocess.run('./build.sh')
                    # process = subprocess.Popen(['./build.sh'])
                    # process.wait()
                    if process.returncode != 0:
                        sys.exit(1)
                    os.chdir(SCRIPT_DIR)


def get_box(box_info, username, vagrant_cloud_token):
    """Attempt to read box from Vagrant Cloud API."""
    build_image = False
    box_api_url = API_URL + 'box'
    url = '{0}/{1}/{2}'.format(box_api_url,
                               username, box_info['box_name'])
    headers = {'Authorization': 'Bearer {0}'.format(
        vagrant_cloud_token)}
    response = requests.get(url, headers=headers)
    json_data = response.json()
    if response.status_code == 200:
        update_box(box_info, username, vagrant_cloud_token)
        current_time = datetime.now(timezone.utc)
        current_version = json_data.get('current_version')
        if current_version is not None:
            last_updated_str = json_data['current_version'][
                'updated_at']
            last_updated_object = datetime.strptime(
                last_updated_str, '%Y-%m-%dT%H:%M:%S.%f%z')
            since_updated_days = (
                current_time - last_updated_object).days
            if since_updated_days > BUILD_OLDER_THAN_DAYS:
                build_image = True
        else:
            build_image = True
    elif response.status_code == 404:
        print('Box missing')
        create_box(box_info, username, vagrant_cloud_token)
        build_image = True
    else:
        print(response.status_code)
    return build_image


def create_box(box_info, username, vagrant_cloud_token):
    """Create box if missing using Vagrant Cloud API."""
    boxes_api_url = API_URL + 'boxes'
    url = '{0}/'.format(boxes_api_url)
    headers = {'Content-Type': 'application/json',
               'Authorization': 'Bearer {0}'.format(vagrant_cloud_token)}
    payload = {
        'box':
        {
            'username': username,
            'name': box_info['box_name'],
            'is_private': box_info['private'].lower(),
            'short_description': box_info['short_description'],
            'description': box_info['description']}
    }
    response = requests.post(url, headers=headers, data=json.dumps(payload))
    json_response = response.json()
    if response.status_code != 200:
        print(response.status_code)
    else:
        print(json_response)


def update_box(box_info, username, vagrant_cloud_token):
    """Update box info using Vagrant Cloud API."""
    box_api_url = API_URL + 'box'
    url = '{0}/{1}/{2}'.format(box_api_url,
                               username, box_info['box_name'])
    headers = {'Content-Type': 'application/json',
               'Authorization': 'Bearer {0}'.format(vagrant_cloud_token)}
    payload = {
        'box':
        {
            'name': box_info['box_name'],
            'is_private': box_info['private'].lower(),
            'short_description': box_info['short_description'],
            'description': box_info['description']}
    }
    print('Updating box: {0}/{1} info.'.format(username, box_info['box_name']))
    response = requests.put(url, headers=headers, data=json.dumps(payload))
    json_response = response.json()
    if response.status_code != 200:
        print(response.status_code)
        print(json_response)


def change_controller(args):
    """Change hard drive controller type for all templates."""
    controller_type = args.controller
    for root, _dirs, files in os.walk(SCRIPT_DIR):
        for _index, item in enumerate(files):
            _filename, ext = os.path.splitext(item)
            if ext == '.json':
                try:
                    json_file = os.path.join(root, item)
                    with open(json_file, 'r') as stream:
                        data = json.load(stream)
                        try:
                            controller = data['variables'][
                                'disk_adapter_type']
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
    print('Cleaning up any lingering build data.')
    for root, dirs, files in os.walk(SCRIPT_DIR):
        for item in dirs:
            if 'output-' in item:
                shutil.rmtree(os.path.join(root, item))
            if item == '.vagrant':
                shutil.rmtree(os.path.join(root, item))
            # if item == 'packer_cache':
            #     shutil.rmtree(os.path.join(root, item))

        for item in files:
            filename, ext = os.path.splitext(item)
            if filename == 'Vagrantfile':
                os.remove(os.path.join(root, item))
            if ext == '.box':
                os.remove(os.path.join(root, item))
            # if ext == '.iso':
            #     os.remove(os.path.join(root, item))


def rename_templates():
    """Renames legacy template names to more standardized template.json."""
    print('Renaming templates to follow standard naming.')
    for root, _dirs, files in os.walk(SCRIPT_DIR):
        for _index, item in enumerate(files):
            _filename, ext = os.path.splitext(item)
            if ext == '.json':
                try:
                    json_file = os.path.join(root, item)
                    with open(json_file, 'r') as stream:
                        data = json.load(stream)
                        try:
                            _vm_name = data['vm_name']
                            json_template = os.path.join(root, 'template.json')
                            build_script = os.path.join(root, 'build.sh')
                            with open(build_script, 'r') as build_script_data:
                                read_data = build_script_data.read()
                                read_data = read_data.replace(
                                    item, 'template.json')
                            with open(build_script, 'w') as (
                                    build_script_data):
                                build_script_data.write(read_data)
                            process = subprocess.Popen(
                                ['git', 'add', build_script])
                            process.wait()
                            if item != 'template.json':
                                process = subprocess.Popen([
                                    'git', 'mv', json_file, json_template])
                                process.wait()
                        except KeyError:
                            pass
                except TypeError:
                    pass


def upload_boxes(username, vagrant_cloud_token):
    """Looks for upload_boxes script in each directory and then executes it."""
    print('Uploading all images.')
    boxes = dict()
    get_boxes(boxes, vagrant_cloud_token)
    for root, _dirs, files in os.walk(SCRIPT_DIR):
        if root != SCRIPT_DIR:
            if 'box_info.json' in files:
                with open(os.path.join(root, 'box_info.json'),
                          'r') as box_info_file:
                    box_info = json.load(box_info_file)
                    box_tag = box_info['box_tag']
                    box_check = boxes.get(box_tag)
                    if box_check is None:
                        create_box(box_info, username, vagrant_cloud_token)
                        get_boxes(boxes, vagrant_cloud_token)
                    existing_versions = boxes.get(box_tag)['versions']
                    for file in files:
                        if file.endswith('.box'):
                            box_path = os.path.join(root, file)
                            box_provider_name = file.split('-')[4]
                            box_version = file.split(
                                '-')[5].split('.box')[0]
                            version_exists = False
                            provider_exists = False
                            for version in existing_versions:
                                if version['version'] == box_version:
                                    version_exists = True
                                    version_providers = version.get(
                                        'providers')
                                    if version_providers is not None:
                                        for provider in version_providers:
                                            if box_provider_name in provider[
                                                    'name']:
                                                provider_exists = True
                                                break
                                    break
                            # We convert vmware provider to vmware_desktop
                            if box_provider_name == 'vmware':
                                box_provider_name = 'vmware_desktop'
                            if not version_exists:
                                create_box_version(
                                    box_tag, box_version, vagrant_cloud_token)
                                create_box_provider(
                                    box_tag, box_version, box_provider_name,
                                    vagrant_cloud_token)
                                upload_box(box_tag, box_path,
                                           box_version, box_provider_name,
                                           vagrant_cloud_token)
                            if version_exists and not provider_exists:
                                create_box_provider(
                                    box_tag, box_version, box_provider_name,
                                    vagrant_cloud_token)
                                upload_box(box_tag, box_path,
                                           box_version, box_provider_name,
                                           vagrant_cloud_token)


def create_box_version(box_tag, box_version, vagrant_cloud_token):
    """Create box version if missing using Vagrant Cloud API."""
    box_api_url = API_URL + 'box'
    url = '{0}/{1}/versions'.format(box_api_url, box_tag)
    headers = {'Content-Type': 'application/json',
               'Authorization': 'Bearer {0}'.format(vagrant_cloud_token)}
    payload = {'version': {'version': box_version}}
    response = requests.post(url, headers=headers, data=json.dumps(payload))
    json_response = response.json()
    if response.status_code != 200:
        print(json_response)
        print(response.status_code)
        sys.exit(1)
    print(json_response)


def create_box_provider(box_tag, box_version, box_provider_name,
                        vagrant_cloud_token):
    """Create box version provider if missing using Vagrant Cloud API."""
    box_api_url = API_URL + 'box'
    url = '{0}/{1}/version/{2}/providers'.format(
        box_api_url, box_tag, box_version)
    headers = {'Content-Type': 'application/json',
               'Authorization': 'Bearer {0}'.format(vagrant_cloud_token)}
    payload = {'provider': {'name': box_provider_name}}
    response = requests.post(url, headers=headers, data=json.dumps(payload))
    json_response = response.json()
    if response.status_code != 200:
        print(response.status_code)
        sys.exit(1)
    print(json_response)


def upload_box(box_tag, box_path, box_version, box_provider_name,
               vagrant_cloud_token):
    """Upload box to Vagrant Cloud."""
    box_api_url = API_URL + 'box'
    url = '{0}/{1}/version/{2}/provider/{3}/upload'.format(
        box_api_url, box_tag, box_version, box_provider_name)
    headers = {'Content-Type': 'application/json',
               'Authorization': 'Bearer {0}'.format(vagrant_cloud_token)}
    # Get upload path
    response = requests.get(url, headers=headers)
    json_response = response.json()
    upload_path = json_response.get('upload_path')
    files = {'file': open(box_path, 'rb')}
    print('Uploading box: {1} version: {2} provider: {3}'.format(
        box_tag, box_version, box_provider_name))
    # Upload box
    response = requests.post(upload_path, files=files)
    json_response = response.json()
    if response.status_code == 200:
        url = '{0}/{1}/version/{2}/release'.format(
            box_api_url, box_tag, box_version)
        # Release version
        response = requests.put(url, headers=headers)
        json_response = response.json()
        if response.status_code != 200:
            print(response.status_code)
            print(json_response)
            sys.exit(1)
        print(json_response)
    else:
        print(response.status_code)
        print(json_response)
        sys.exit(1)
    print(json_response)


def commit_manifests(repo_facts):
    """Auto commit manifests."""
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
    """Find build manifests and display to stdout."""
    for root, _dirs, files in os.walk(SCRIPT_DIR):
        if 'manifest.json' in files:
            json_file = os.path.join(root, 'manifest.json')
            try:
                with open(json_file, 'r') as stream:
                    data = json.load(stream)
                    print(json.dumps(data, indent=4))
            except ValueError:
                pass


def view_last_build_times():
    """Find build manifests and display to stdout."""
    build_manifests = dict()
    for root, _dirs, files in os.walk(SCRIPT_DIR):
        if 'manifest.json' in files and 'box_info.json' in files:
            box_info = os.path.join(root, 'box_info.json')
            try:
                with open(box_info, 'r') as box_data:
                    box_tag = json.load(box_data).get('box_tag')
            except ValueError:
                pass

            manifest = os.path.join(root, 'manifest.json')
            try:
                with open(manifest, 'r') as manifest_data:
                    data = json.load(manifest_data)
                    last_run_uuid = data.get('last_run_uuid')
                    builds = data.get('builds')
                    if builds is not None:
                        for build in builds:
                            if build['packer_run_uuid'] == last_run_uuid:
                                current_time_epoch = time.mktime(
                                    datetime.now().timetuple())
                                last_build_time_epoch = build['build_time']
                                build_manifests[box_tag] = dict(
                                    days_since_last_build=int(
                                        (current_time_epoch -
                                         last_build_time_epoch)/86400))
            except ValueError:
                pass
    print(json.dumps(build_manifests))


if __name__ == '__main__':
    main()
