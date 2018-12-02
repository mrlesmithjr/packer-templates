#! /usr/bin/env python
"""Just a small little script to help manage Packer templates in this repo."""

import argparse
import datetime
import json
import logging
import os
import shutil
import time
import git

__author__ = "Larry Smith Jr."
__email__ = "mrlesmithjr@gmail.com"
__maintainer__ = "Larry Smith Jr."
__status__ = "Development"
# http://everythingshouldbevirtual.com
# @mrlesmithjr

logging.basicConfig(level=logging.INFO)


BUILD_OLDER_THAN_DAYS = 30


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
            'commit_manifests', 'rename_templates',
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
        upload_boxes()
    elif args.action == 'change_controller':
        change_controller(args)
    elif args.action == 'cleanup_builds':
        cleanup_builds()
    elif args.action == 'commit_manifests':
        repo_facts = dict()
        repo_info(repo_facts)
        commit_manifests(repo_facts)
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
    for root, dirs, files in os.walk(os.getcwd()):
        for item in files:
            if item == 'build.sh':
                with open(os.path.join(root, 'box_info.json'),
                          'r') as box_info:
                    data = json.load(box_info)
                    try:
                        auto_build = data['auto_build']
                    except KeyError:
                        auto_build = True
                if auto_build:
                    build_image = latest_build(root)
                    if build_image:
                        print 'Executing build.sh in {0}'.format(root)
                        os.chdir(root)
                        os.system('./{0}'.format(item))


def change_controller(args):
    """Change hard drive controller type for all templates."""
    controller_type = args.controller
    for root, dirs, files in os.walk(os.getcwd()):
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
                                with open(json_file, 'w') as (
                                        json_file_data):
                                    json_file_data.write(read_data)
                        except KeyError:
                            pass
                except TypeError:
                    pass


def cleanup_builds():
    """Clean up lingering build data and artifacts."""
    print 'Cleaning up any lingering build data.'
    for root, dirs, files in os.walk(os.getcwd()):
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
    for root, dirs, files in os.walk(os.getcwd()):
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
    parent_path = os.getcwd()
    for root, dirs, files in os.walk(parent_path):
        if root != parent_path:
            for item in files:
                if item == 'upload_boxes.sh':
                    print 'Executing upload_boxes.sh in {0}'.format(root)
                    os.chdir(root)
                    os.system('./{0}'.format(item))


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
        commit_date = datetime.datetime.now().strftime('%Y-%m-%d-%H-%M-%S')
        commit_msg = '{} - Manifest Updates'.format(commit_date)
        repo.git.commit('-m', '{}'.format(commit_msg))
        repo.git.push()


def view_manifests():
    for root, dirs, files in os.walk(os.getcwd()):
        for index, item in enumerate(files):
            if item == 'manifest.json':
                json_file = os.path.join(root, item)
                with open(json_file, 'r') as stream:
                    data = json.load(stream)
                    print json.dumps(data, indent=4)


def latest_build(root):
    build_image = False
    current_time_epoch = time.mktime(datetime.datetime.now().timetuple())
    older_than_days_epoch = current_time_epoch - \
        (86400 * BUILD_OLDER_THAN_DAYS)
    older_than_days = int((older_than_days_epoch/86400) + 25569)
    json_file = os.path.join(root, 'manifest.json')
    if os.path.isfile(json_file):
        with open(json_file, 'r') as stream:
            data = json.load(stream)
            last_run_uuid = data['last_run_uuid']
            builds = data['builds']
            for build in builds:
                if build['packer_run_uuid'] == last_run_uuid:
                    last_build_time_epoch = build['build_time']
                    last_build_time = int(
                        (last_build_time_epoch/86400) + 25569)
                    if last_build_time < older_than_days:
                        build_image = True
                    break
    else:
        build_image = True
    return build_image


if __name__ == '__main__':
    main()
