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
import shlex
import subprocess
from typing import Any


def meson_source_root() -> Path:
    return Path(os.environ['MESON_SOURCE_ROOT'])


@lru_cache
def meson_introspect(keyword: str) -> Any:
    cmd = shlex.split(os.environ['MESONINTROSPECT']) + [f'--{keyword}']
    return json.loads(subprocess.check_output(cmd))


def meson_host() -> str:
    system = meson_introspect('machines')['host']['system']
    assert isinstance(system, str)
    return system


def parse_ini_file(path: Path) -> configparser.RawConfigParser:
    with path.open() as fh:
        ini = configparser.RawConfigParser()
        ini.read_file(fh)
        return ini


def default_version() -> str:
    # try the version pinned by 'meson dist'
    try:
        ver = (meson_source_root() / 'version').read_text().strip()
        # append "-local" if missing
        if '-local' not in ver:
            ver += '-local'
        return ver
    except FileNotFoundError:
        return date.today().strftime('%Y%m%d') + '-local'
