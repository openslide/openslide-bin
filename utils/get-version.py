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

import os
import sys

# handle our own PYTHONPATH prepending, since meson can't do it this early
# flake8 isn't happy about this
sys.path.insert(0, os.environ['MESON_SOURCE_ROOT'])

from common.meson import default_suffix, project_version  # noqa: E402

suffix = os.environ.get('OPENSLIDE_BIN_SUFFIX', default_suffix())
print(project_version(suffix))
