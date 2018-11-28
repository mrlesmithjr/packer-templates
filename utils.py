#! /usr/bin/env python
"""Just a small little script to help manage Packer templates in this repo."""

import os
import json
import argparse
import logging
import git

__author__ = "Larry Smith Jr."
__email__ = "mrlesmithjr@gmail.com"
__maintainer__ = "Larry Smith Jr."
__status__ = "Development"
# http://everythingshouldbevirtual.com
# @mrlesmithjr

logging.basicConfig(level=logging.INFO)


def main():
    """Main program execution."""
    args = parse_args()
    decide_action(args)


def parse_args():
    """Parse CLI arguments."""
    parser = argparse.ArgumentParser(description="Packer template utils.")
    parser.add_argument(
        "action", help="Define action to take.", choices=[
            'build_all', 'cleanup_builds', 'rename_templates', 'repo_info',
            'upload_boxes'])
    args = parser.parse_args()
    return args


def decide_action(args):
    """Make decision on what to do from arguments being passed."""
    if args.action == 'build_all':
        build_all()
    elif args.action == 'cleanup_builds':
        cleanup_builds()
    elif args.action == 'rename_templates':
        rename_templates()
    elif args.action == 'repo_info':
        repo_facts = dict()
        repo_info(repo_facts)
        print json.dumps(repo_facts, indent=4)
    elif args.action == 'upload_boxes':
        upload_boxes()


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
                print 'Executing build.sh in {0}'.format(root)
                os.chdir(root)
                os.system('./{0}'.format(item))


def cleanup_builds():
    """Clean up lingering build data and artifacts."""
    print 'Cleaning up any lingering build data.'
    for root, dirs, files in os.walk(os.getcwd()):
        for item in dirs:
            if 'output-' in item:
                os.rmdir(os.path.join(root, item))
            if item == '.vagrant':
                os.rmdir(os.path.join(root, item))
            if item == 'packer_cache':
                os.rmdir(os.path.join(root, item))

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
    for root, dirs, files in os.walk(os.getcwd()):
        for item in files:
            if item == 'upload_boxes.sh':
                print 'Executing upload_boxes.sh in {0}'.format(root)
                os.chdir(root)
                os.system('./{0}'.format(item))


if __name__ == '__main__':
    main()
