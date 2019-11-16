#!/usr/bin/env python3

import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--list', action="store_true")
parser.add_argument('--host')
args = parser.parse_args()
if args.list:
    print('''{
    "_meta": {
        "hostvars": {
            "appserver": {
                "ansible_host": "35.235.33.108"
            },
            "dbserver": {
                "ansible_host": "35.246.185.151"
            }
        }
    },
    "all": {
        "children": [
            "app",
            "db",
            "ungrouped"
        ]
    },
    "app": {
        "hosts": [
            "appserver"
        ]
    },
    "db": {
        "hosts": [
            "dbserver"
        ]
    }
} 
''')
elif args.host == "appserver":
    print('{ "ansible_host": "35.235.33.108" }')

elif args.host == "dbserver":
    print('{ "ansible_host": "35.246.185.151" }')

else:
    print("{}")
