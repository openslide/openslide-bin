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

from pathlib import PurePath
import re


class BDistName:
    def __init__(self, name: str):
        match = re.match(
            '(openslide-bin-.+-(linux|macos|windows)-.+)\\.(tar\\.xz|zip)$',
            name,
        )
        if not match:
            raise ValueError('Not a bdist archive')
        self.base = PurePath(match[1])
        self.system: str = match[2]
        self.format: str = match[3]
        self.system_display = {
            'linux': 'Linux',
            'macos': 'macOS',
            'windows': 'Windows',
        }[self.system]
