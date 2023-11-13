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

from ctypes import c_char_p, c_void_p
import os

os.environ['OPENSLIDE_DEBUG'] = 'synthetic'

import openslide_bin  # noqa: E402

openslide_open = openslide_bin.libopenslide1.openslide_open
openslide_open.argtypes = [c_char_p]
openslide_open.restype = c_void_p

openslide_get_error = openslide_bin.libopenslide1.openslide_get_error
openslide_get_error.argtypes = [c_void_p]
openslide_get_error.restype = c_char_p

osr = openslide_open(b'-----eCRFEcGBT+RN8+6rLZQz5gUA0ymSdPE-----')
assert osr is None

osr = openslide_open(b'')
assert osr is not None
assert openslide_get_error(osr) is None
