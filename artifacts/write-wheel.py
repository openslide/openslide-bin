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
from contextlib import ExitStack
from email.message import Message
from io import BytesIO
import os
from pathlib import Path
import re
import subprocess
from typing import BinaryIO

from common.archive import FileMember, WheelWriter
from common.argparse import TypedArgs
from common.meson import meson_host
from common.python import pyproject_to_message


class Args(TypedArgs):
    artifacts: list[Path]
    output: BinaryIO


args = Args('write-wheel', description='Write Python wheel.')
args.add_arg(
    '-o',
    '--output',
    type=argparse.FileType('wb'),
    required=True,
    help='output file',
)
args.add_arg(
    'artifacts',
    metavar='artifact',
    nargs='+',
    type=Path,
    help='built artifact',
)
args.parse()

with ExitStack() as inputs:
    with WheelWriter(args.output) as whl:
        for path in args.artifacts:
            if path.is_file():
                fh = inputs.enter_context(path.open('rb'))
            if path.name == 'pyproject.toml':
                meta = pyproject_to_message(fh.read().decode())
                whl.add(
                    FileMember(
                        whl.metadir / 'METADATA', BytesIO(meta.as_bytes())
                    )
                )
            elif path.name == 'licenses':
                whl.add_tree(whl.metadir, path)
            else:
                name = re.sub('(\\.so\\.[0-9]+)\\.[0-9.]+', '\\1', path.name)
                whl.add(FileMember(whl.datadir / name, fh))

        meta = Message()
        meta['Wheel-Version'] = '1.0'
        meta['Generator'] = 'openslide-bin'
        meta['Root-Is-Purelib'] = 'false'
        meta['Tag'] = whl.tag
        whl.add(FileMember(whl.metadir / 'WHEEL', BytesIO(meta.as_bytes())))

if meson_host() == 'linux':
    report = subprocess.check_output(
        [
            os.environ['AUDITWHEEL'],
            'show',
            args.output.name,
        ],
    ).decode()
    if f'"{whl.platform}"' not in report:
        raise Exception(f'Wheel audit failed: {report}')
