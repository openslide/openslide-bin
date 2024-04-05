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
from pathlib import Path, PurePath
import re
from typing import BinaryIO

from common.archive import (
    ArchiveWriter,
    FileMember,
    SymlinkMember,
    TarArchiveWriter,
    ZipArchiveWriter,
)
from common.argparse import TypedArgs
from common.meson import meson_host
from common.software import Project


class Args(TypedArgs):
    artifacts: list[Path]
    output: BinaryIO


args = Args('write-bdist', description='Write bdist archive.')
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

if meson_host() == 'windows':
    arc: ArchiveWriter = ZipArchiveWriter(args.output)
else:
    arc = TarArchiveWriter(args.output)
with arc:
    for path in args.artifacts:
        name = path.name
        if re.search('\\.(lib|dylib(\\.dSYM)?|so[.0-9]*(\\.debug)?)$', name):
            arcdir = arc.base / 'lib'
        elif name.endswith('.h'):
            arcdir = arc.base / 'include' / 'openslide'
        elif name in (
            'CHANGELOG.md',
            'VERSIONS.md',
            'versions.json',
            'licenses',
        ):
            arcdir = arc.base
        else:
            arcdir = arc.base / 'bin'

        if path.is_dir():
            arc.add_tree(arcdir, path)
        else:
            arc.add(FileMember(arcdir / name, path.open('rb')))
            if re.search('\\.so(\\.[0-9]+){3}$', name):
                for pat in '(\\.[0-9]+){2}$', '(\\.[0-9]+)+$':
                    lname = re.sub(pat, '', name)
                    arc.add(SymlinkMember(arcdir / lname, PurePath(name)))
            elif re.search('\\.[0-9]+\\.dylib$', name):
                lname = re.sub('\\.[0-9]+\\.dylib$', '.dylib', name)
                arc.add(SymlinkMember(arcdir / lname, PurePath(name)))

    # special case: copy OpenSlide README to root
    arc.add(
        FileMember(
            arc.base / 'README.md',
            open(Project.get('openslide').source_dir / 'README.md', 'rb'),
        )
    )
