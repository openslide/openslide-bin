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

from pathlib import Path
import shutil

from common.argparse import TypedArgs


class Args(TypedArgs):
    dll: Path
    output: Path


args = Args('write-import-library', description='Write import library.')
args.add_arg('dll', type=Path, help='built DLL')
args.add_arg('output', type=Path, help='output import library')
args.parse()

# We don't actually generate an import library, we just copy the one that's
# already built, changing the file extension in the process.  This is
# necessary because the import library is generated as a side effect of
# building the DLL and isn't addressable in Meson.  By adding an explicit
# build step, we make it addressable.
basename = '-'.join(args.dll.name.split('-')[0:-1])
shutil.copy2(args.dll.with_name(f'{basename}.dll.a'), args.output)
