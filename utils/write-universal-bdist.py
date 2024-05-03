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
from pathlib import Path
import tempfile
from typing import BinaryIO, cast

from common.archive import (
    DirMember,
    FileMember,
    SymlinkMember,
    TarArchiveReader,
    TarArchiveWriter,
)
from common.argparse import TypedArgs
from common.macos import all_equal, merge_macho

DSYM_ARCHES = {'aarch64', 'x86_64'}


class Args(TypedArgs):
    bdists: list[BinaryIO]
    output: BinaryIO


args = Args(
    'write-universal-bdist', description='Write macOS universal bdist archive.'
)
args.add_arg(
    '-o',
    '--output',
    type=argparse.FileType('wb'),
    required=True,
    help='output file',
)
args.add_arg(
    'bdists',
    metavar='bdist',
    nargs='+',
    type=argparse.FileType('rb'),
    help='input file',
)
args.parse()

with ExitStack() as stack:
    tempdir = Path(
        stack.enter_context(
            tempfile.TemporaryDirectory(prefix='openslide-bin-')
        )
    )
    readers = stack.enter_context(TarArchiveReader.group(args.bdists))
    out = stack.enter_context(TarArchiveWriter(args.output))
    for members in readers:
        if all_equal(type(m) for m in members):
            all_type: type | None = type(members[0])
        else:
            all_type = None
        if not all_equal(members.relpaths):
            # path mismatch, which we only allow for dSYM relocations.
            # ensure we have a path component which is a dSYM arch
            if not all(
                DSYM_ARCHES.intersection(p.parts) for p in members.relpaths
            ):
                raise Exception(f'Path mismatch: {members.relpaths}')
            if all_type in (DirMember, FileMember):
                for member in members:
                    out.add(member.with_base(out.base))
            else:
                raise Exception(
                    'Unknown/mismatched types for relocations: '
                    f'{members.relpaths}'
                )
        elif all_type is DirMember or (
            all_type is SymlinkMember
            and all_equal(cast(SymlinkMember, m).target for m in members)
        ):
            out.add(members[0].with_base(out.base))
        elif all_type is FileMember:
            if (
                len(members.datas[0]) >= 4
                and members.datas[0][0:4] == b'\xcf\xfa\xed\xfe'
            ):
                macho_path = merge_macho(
                    [Path(cast(FileMember, m).fh.name) for m in members],
                    tempdir,
                )
                out.add(
                    FileMember(
                        out.base / members[0].relpath,
                        open(macho_path, 'rb'),
                    )
                )
            elif all_equal(members.datas):
                out.add(members[0].with_base(out.base))
            else:
                raise Exception(f'Contents mismatch: {members.relpaths}')
        else:
            raise Exception(f'Unknown/mismatched types: {members.relpaths}')
