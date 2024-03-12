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
import os
import re
import subprocess
from typing import TextIO

from common.argparse import TypedArgs
from common.meson import meson_host, meson_introspect
from common.software import (
    Project,
    Software,
    Tool,
    get_software_info,
    write_version_markdown,
)

MINGW_VERSION_CHECK_HDR = b'''
#include <_mingw_mac.h>
#define s(v) #v
#define ss(v) s(v)
ss(__MINGW64_VERSION_MAJOR).ss(__MINGW64_VERSION_MINOR).ss(__MINGW64_VERSION_BUGFIX)
'''


class Args(TypedArgs):
    json: TextIO
    markdown: TextIO


args = Args(
    'write-project-versions', description='Write subproject version list.'
)
args.add_arg(
    '-j',
    '--json',
    type=argparse.FileType('w'),
    required=True,
    help='output JSON',
)
args.add_arg(
    '-m',
    '--markdown',
    type=argparse.FileType('w'),
    required=True,
    help='output Markdown',
)
args.parse()

sw: list[Software] = list(Project.get_enabled())
compiler = meson_introspect('compilers')['host']['c']
if meson_host() == 'windows':
    out = subprocess.Popen(
        compiler['exelist'] + ['-E', '-'],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
    ).communicate(MINGW_VERSION_CHECK_HDR)[0]
    ver = [
        line
        for line in out.decode().split('\n')
        if line.strip() and not line.startswith('#')
    ][0].replace('"', '')
    sw.append(Tool(id='mingw-w64', display='MinGW-w64', version=ver))
if compiler['id'] == 'gcc':
    ver = compiler['full_version']
    match = re.match('[^ ]+ (.+)', ver)
    if match:
        ver = match[1]
    sw.append(Tool(id='gcc', display='GCC', version=ver))
    ver = (
        subprocess.check_output([os.environ['LD'], '--version'])
        .decode()
        .split('\n')[0]
    )
    sw.append(Tool(id='binutils', display='Binutils', version=ver))
elif compiler['id'] == 'clang':
    ver = re.sub('.* version ', '', compiler['full_version'])
    sw.append(Tool(id='clang', display='Clang', version=ver))

info = get_software_info(sw)
with args.json as fh:
    json.dump(info, fh, indent=2, sort_keys=True)
    fh.write('\n')
with args.markdown as fh:
    write_version_markdown(fh, info)
