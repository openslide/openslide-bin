#!/usr/bin/env python3
#
# Tools for building OpenSlide and its dependencies
#
# Copyright (c) 2011-2015 Carnegie Mellon University
# Copyright (c) 2022-2023 Benjamin Gilbert
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

import os
from pathlib import Path
import re
import subprocess

from common.argparse import TypedArgs
from common.meson import meson_host


def library_symbols(file: Path) -> list[str]:
    if host == 'linux':
        out = subprocess.check_output(
            [os.environ['OBJDUMP'], '-T', file]
        ).decode()
        return [line.split()[6] for line in out.split('\n') if '.text' in line]
    elif host == 'darwin':
        out = subprocess.check_output(
            [os.environ['DYLD_INFO'], '-exports', file]
        ).decode()
        return [
            line.split()[1].lstrip('_')
            for line in out.split('\n')
            if ' 0x' in line
        ]
    elif host == 'windows':
        out = subprocess.check_output(
            [os.environ['OBJDUMP'], '-p', file]
        ).decode()
        active = False
        syms: list[str] = []
        for line in out.split('\n'):
            if active:
                if not line.strip():
                    return syms
                sym = line.split()[-1]
                if sym != 'Name':
                    syms.append(sym)
            elif 'Ordinal/Name Pointer' in line:
                active = True
        raise Exception("Couldn't parse objdump output")
    else:
        raise Exception(f'Unknown host: {host}')


class Args(TypedArgs):
    file: Path
    output: Path
    debuginfo: Path


args = Args(
    'postprocess-binary', description='Mangle shared library or executable.'
)
args.add_arg('-o', '--output', type=Path, required=True, help='output file')
args.add_arg(
    '-d', '--debuginfo', type=Path, required=True, help='output debug symbols'
)
args.add_arg('file', type=Path, help='input file')
args.parse()
host = meson_host()

# split debuginfo
if host == 'darwin':
    subprocess.check_call(
        [os.environ['DSYMUTIL'], '-o', args.debuginfo, args.file]
    )
    subprocess.check_call(
        [os.environ['STRIP'], '-u', '-r', '-o', args.output, args.file]
    )
else:
    objcopy = os.environ['OBJCOPY']
    subprocess.check_call(
        [objcopy, '--only-keep-debug', args.file, args.debuginfo]
    )
    os.chmod(args.debuginfo, 0o644)
    # debuglink without a directory path enables search semantics
    assert args.debuginfo.parent == args.output.parent
    subprocess.check_call(
        [
            objcopy,
            '-S',
            f'--add-gnu-debuglink={args.debuginfo.name}',
            args.file.absolute(),
            args.output.absolute(),
        ],
        cwd=args.debuginfo.parent,
    )

# check for extra symbol exports
if re.search('\\.(dll|dylib|so[.0-9]*)$', args.file.name):
    syms = library_symbols(args.file)
    if not syms:
        raise Exception(f"Couldn't find exported symbols in {args.file}")
    syms = [
        # filter out acceptable symbols
        sym
        for sym in syms
        if not sym.startswith('openslide_')
    ]
    if syms:
        raise Exception(f'Unexpected exports in {args.file}: {syms}')

# update rpath
if host == 'linux' and not re.match('\\.so[.0-9]*$', args.file.name):
    subprocess.check_call(
        [os.environ['PATCHELF'], '--set-rpath', '$ORIGIN/../lib', args.output]
    )
elif host == 'darwin' and not args.file.name.endswith('.dylib'):
    out = subprocess.check_output(
        [os.environ['OTOOL'], '-l', args.output]
    ).decode()
    active = False
    for line in out.split('\n'):
        if 'cmd LC_RPATH' in line:
            active = True
        elif active:
            words = line.split()
            if words[0] == 'path':
                old_rpath = words[1]
                break
    else:
        raise Exception("Couldn't read LC_RPATH")
    subprocess.check_call(
        [
            os.environ['INSTALL_NAME_TOOL'],
            '-rpath',
            old_rpath,
            '@loader_path/../lib',
            args.output,
        ]
    )
