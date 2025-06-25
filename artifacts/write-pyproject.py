#!/usr/bin/env python3
#
# Tools for building OpenSlide and its dependencies
#
# Copyright (c) 2023-2025 Benjamin Gilbert
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
from typing import TextIO

from common.argparse import TypedArgs
from common.python import pyproject_fill_template


class Args(TypedArgs):
    input: TextIO
    output: TextIO


args = Args('write-pyproject', description='Write pyproject.toml.')
args.add_arg(
    'input',
    type=argparse.FileType('r'),
    help='input template file',
)
args.add_arg(
    'output',
    type=argparse.FileType('w'),
    help='output file',
)
args.parse()

with args.input:
    pyproject = pyproject_fill_template(args.input.read())
with args.output:
    args.output.write(pyproject)
