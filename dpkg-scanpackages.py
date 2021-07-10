#!/bin/env python3
# -*- coding: utf-8 -*-

# TODO: 根据 info.json 和 description.md 自动生成 info.xml 和 SileoDepiction.json

import os
import subprocess
import re
import json
import sys
import getopt

VERSION = '0.0.1'


fieldpri = ['Package',
            'Source',
            'Version',
            'Priority',
            'Section',
            'Essential',
            'Maintainer',
            'Pre-Depends',
            'Depends',
            'Recommends',
            'Suggests',
            'Conflicts',
            'Provides',
            'Replaces',
            'Enhances',
            'Architecture',
            'Filename',
            'Size',
            'Installed-Size',
            'MD5sum',
            'SHA1sum',
            'SHA256sum',
            'Description',
            'Origin',
            'Bugs',
            'Name',
            'Author',
            'Homepage',
            'Website',
            'Depiction',
            'SileoDepiction',
            'Icon'
            ]


def help(*argv) -> None:
    print(f"""
Usage: {os.path.basename(__file__)} [<option> ...] <binarypath> <overridefile> [<pathprefix>] > Packages

Options:
  -u, --udeb               scan for udebs.
  -a, --arch <arch>        architecture to scan for.
  -m, --multiversion       allow multiple versions of a single package.
  -h, --help               show this help message.
      --version            show the version.
""")


def walk() -> list:
    pkgs = []
    for root, dirs, files in os.walk(".", topdown=False):
        for file_path in files:
            if '.deb' in file_path:
                path = os.path.join(root, file_path)
                output = subprocess.getstatusoutput(
                    "dpkg-deb -I %s control" % path)
                if output[0]:
                    print(
                        "\`dpkg-deb -I %s control' exited with %d, skipping package" % (file_path, output[0]))
                    continue
                if output[1] == '':
                    print(
                        "Couldn't call dpkg-deb on %s, skipping package" % file_path)
                    continue
                splln = output[1].splitlines()
                pkg_info = {}
                recomp = re.compile("(\S+):[ \t]*(.*)")
                for ln in splln:
                    key, value = recomp.match(ln).groups()
                    key = key.strip()
                    if key in fieldpri:
                        value = value.strip()
                        pkg_info[key] = value
                try:
                    pkg_info["Package"]
                    pkgs.append(pkg_info)
                except KeyError:
                    print("No Package field in control file of %s" % file_path)
                    continue
    return(pkgs)


if __name__ == "__main__":
    try:
        opts, unrecognized_args = getopt.getopt(sys.argv[1:], "ua:mh", [
            "udeb", "arch=", "multiversion", "help", "version"])
    except getopt.GetoptError:
        help()
        exit(2)
    for arg, opt in opts:
        {
            '-u': lambda opt: print(opt),
            '--udeb': lambda opt: print(opt),
            '-a': lambda opt: print(opt),
            '--arch': lambda opt: print(opt),
            '-m': lambda opt: print(opt),
            '--multiversion': lambda opt: print(opt),
            '-h': help,
            '--help': help,
            '--version': lambda opt: print(VERSION)
        }[arg](opt)

    #print(opts, args)
    #pkgs = walk()
    #print(json.dumps(pkgs, indent=2))
