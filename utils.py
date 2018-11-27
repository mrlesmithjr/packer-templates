#! /usr/bin/env python
import os
import json
import argparse


def main():
    args = parse_args()
    decide_action(args)


def parse_args():
    """Parse CLI arguments."""
    parser = argparse.ArgumentParser(description="Packer template utils.")
    parser.add_argument(
        "action", help="Define action to take.", choices=[
            'cleanup_builds', 'rename_templates'])
    args = parser.parse_args()
    return args


def decide_action(args):
    if args.action == 'cleanup_builds':
        cleanup_builds()
    elif args.action == 'rename_templates':
        rename_templates()


def cleanup_builds():
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
                                with open(build_script, 'w') as build_script_data:
                                    build_script_data.write(read_data)
                            os.system('git add {0}'.format(build_script))
                            if item != 'template.json':
                                os.system('git mv {0} {1}'.format(
                                    json_file, json_template))
                        except KeyError:
                            pass
                except TypeError:
                    pass


if __name__ == '__main__':
    main()
