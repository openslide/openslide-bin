#!/usr/bin/env python3
#
# Tools for building OpenSlide and its dependencies
#
# Copyright (c) 2023 Benjamin Gilbert
# All rights reserved.
#
# This script is free software: you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License, version 2.1,
# as published by the Free Software Foundation.
#
# This script is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
# for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this script. If not, see <http://www.gnu.org/licenses/>.
#

from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys
import tarfile
from typing import BinaryIO, TextIO
import zipfile

from common.argparse import TypedArgs
from common.dist import BDistName
from common.software import Info, Infos, write_version_markdown


class Args(TypedArgs):
    bdists: list[BinaryIO]
    output: TextIO


args = Args(
    'write-combined-project-versions',
    description='Write aggregate version list from bdist archives',
)
args.add_arg(
    '-o',
    '--output',
    type=argparse.FileType('w'),
    default=sys.stdout,
    help='output file',
)
args.add_arg(
    'bdists',
    metavar='bdist',
    nargs='+',
    type=argparse.FileType('rb'),
    help='bdist archive',
)
args.parse()

infos: dict[tuple[str | None, str], Info] = {}
for fh in args.bdists:
    name = BDistName(Path(fh.name).name)
    verfile = (name.base / 'versions.json').as_posix()
    if name.format == 'zip':
        with zipfile.ZipFile(fh) as zip:
            with zip.open(verfile) as zmember:
                contents: Infos = json.load(zmember)
    else:
        with tarfile.open(fileobj=fh) as tar:
            tmember = tar.extractfile(tar.getmember(verfile))
            if tmember is None:
                raise Exception(f'{verfile} is not a file')
            with tmember:
                contents = json.load(tmember)

    for info in contents['versions']:
        id, typ, version = info['id'], info['type'], info['version']
        key = (name.system if typ == 'tool' else None, id)
        if key in infos:
            prev_version = infos[key]['version']
            if prev_version != version:
                raise Exception(
                    f'Version mismatch for {id}: {version} vs. {prev_version}'
                )
        if typ == 'tool':
            info['display'] = f'[{name.system_display}] {info["display"]}'
        infos[key] = info

with args.output:
    write_version_markdown(args.output, {'versions': list(infos.values())})
