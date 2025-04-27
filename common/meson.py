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

import configparser
from datetime import date
from functools import lru_cache
import json
import os
from pathlib import Path
import re
from typing import Any

# A.B.C.D
# A.B.C = OpenSlide version
# D = ordinal of the openslide-bin release with this A.B.C, starting from 1
# Update the version when releasing openslide-bin.
_PROJECT_VERSION = '4.0.0.8'


def meson_source_root() -> Path:
    return Path(os.environ['MESON_SOURCE_ROOT'])


@lru_cache
def meson_introspect(keyword: str) -> Any:
    with open(Path('meson-info') / f'intro-{keyword}.json') as fh:
        return json.load(fh)


def meson_host() -> str:
    system = meson_introspect('machines')['host']['system']
    assert isinstance(system, str)
    return system


def parse_ini_file(path: Path) -> configparser.RawConfigParser:
    with path.open() as fh:
        ini = configparser.RawConfigParser()
        ini.read_file(fh)
        return ini


def project_version(suffix: str) -> str:
    if not re.match('[a-zA-Z0-9.]*$', suffix):
        raise Exception('Invalid character in version suffix')
    if suffix:
        return f'{_PROJECT_VERSION}+{suffix}'
    else:
        return _PROJECT_VERSION


def default_suffix() -> str:
    # try the suffix pinned by 'meson dist'
    try:
        suffix = (meson_source_root() / 'suffix').read_text().strip()
        segments = suffix.split('.') if suffix else []
        # append "local" segment if missing
        if 'local' not in segments:
            segments.append('local')
        return '.'.join(segments)
    except FileNotFoundError:
        return date.today().strftime('%Y%m%d') + '.local'
