#!/usr/bin/env python3
"""Update requirements from the ansible/ansible repository."""

import json
import os
import sys
import urllib.request


def main():
    """Main program entry point."""

    source_requirements = {
        'https://api.github.com/repos/ansible/ansible/contents/test/sanity/code-smell/': 'sanity',
        'https://api.github.com/repos/ansible/ansible/contents/test/units/': 'units',
        'https://api.github.com/repos/ansible/ansible/contents/test/integration/': 'integration',
        'https://api.github.com/repos/ansible/ansible/contents/test/lib/ansible_test/_data/requirements/': '',
    }

    files = []
    untouched_mappings = {}

    for url, label in source_requirements.items():
        with urllib.request.urlopen(url) as response:
            content = json.loads(response.read().decode())

            if not isinstance(content, list):
                content = [content]

            for item in content:
                if label:
                    if not item['name'].endswith('requirements.txt'):
                        continue

                    item['name'] = '%s.%s' % (label, item['name'])
                else:
                    if not item['name'].startswith('integration.cloud.'):
                        continue

                files.append(item)

    requirements_dir = 'requirements'

    untouched_paths = set(os.path.join(requirements_dir, file) for file in os.listdir(requirements_dir))

    for item in files:
        name = item['name']
        download_url = item['download_url']

        path = os.path.join(requirements_dir, name)

        if path in untouched_paths:
            untouched_paths.remove(path)

        with urllib.request.urlopen(download_url) as response:
            latest_contents = response.read().decode()

        if os.path.exists(path):
            with open(path, 'r') as contents_fd:
                current_contents = contents_fd.read()
        else:
            current_contents = ''

        if latest_contents == current_contents:
            print('%s: current' % path)
            continue

        with open(path, 'w') as contents_fd:
            contents_fd.write(latest_contents)

        print('%s: updated' % path)

    for path in untouched_paths:
        os.unlink(path)

        print('%s: deleted' % path)

    # Error on any rename mappings that were not used to catch typos in the mapping or files that no longer exist
    for url in untouched_mappings:
        for m in untouched_mappings[url]:
            print('ERROR: Unable to rename %s from %s' % (m, url))

    if any(untouched_mappings[url] for url in untouched_mappings):
        sys.exit(1)


if __name__ == '__main__':
    main()
