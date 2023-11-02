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

import configparser
from dataclasses import dataclass
from functools import cached_property
from pathlib import Path
import subprocess
from typing import TextIO

from .meson import meson_introspect, meson_source_root, parse_ini_file


@dataclass
class Project:
    id: str
    display: str
    primary: bool = False

    @staticmethod
    def get_enabled() -> list[Project]:
        enabled = {
            s['name'] for s in meson_introspect('projectinfo')['subprojects']
        }
        ret = [p for p in _PROJECTS if p.id in enabled]
        unknown = enabled - _PROJECTS_IGNORE - {p.id for p in ret}
        if unknown:
            raise Exception(f'Unknown projects: {unknown}')
        return ret

    @cached_property
    def wrap(self) -> configparser.RawConfigParser:
        return parse_ini_file(self.wrap_path)

    @property
    def wrap_path(self) -> Path:
        return meson_source_root() / 'subprojects' / f'{self.id}.wrap'

    @cached_property
    def version(self) -> str:
        try:
            # get the wrapdb_version, including the package revision
            ver = self.wrap.get('wrap-file', 'wrapdb_version', fallback=None)
            if not ver:
                # older or non-wrapdb wrap; parse the directory name
                ver = self.wrap.get('wrap-file', 'directory').split('-')[-1]
            return ver
        except FileNotFoundError:
            # overridden source directory
            # if it's a Git repo, use 'git describe'
            if (self.source_dir / '.git').exists():
                return (
                    subprocess.check_output(
                        ['git', 'describe', '--always', '--dirty'],
                        cwd=self.source_dir,
                    )
                    .decode()
                    .strip()
                )
            # ask the subproject (may not be reliable, e.g. proxy-libintl)
            for sub in meson_introspect('projectinfo')['subprojects']:
                if sub['name'] == self.id:
                    version = sub['version']
                    assert isinstance(version, str)
                    return version
            raise Exception(f'Missing project info for {self.id}')

    @cached_property
    def source_dir(self) -> Path:
        try:
            dirname = self.wrap.get('wrap-file', 'directory')
        except FileNotFoundError:
            # overridden source directory
            dirname = self.id
        return meson_source_root() / 'subprojects' / dirname


_PROJECTS = (
    Project(
        id='cairo',
        display='cairo',
    ),
    Project(
        id='gdk-pixbuf',
        display='gdk-pixbuf',
    ),
    Project(
        id='glib',
        display='glib',
    ),
    Project(
        id='libdicom',
        display='libdicom',
    ),
    Project(
        id='libffi',
        display='libffi',
    ),
    Project(
        id='libjpeg-turbo',
        display='libjpeg-turbo',
    ),
    Project(
        id='libopenjp2',
        display='OpenJPEG',
    ),
    Project(
        id='libpng',
        display='libpng',
    ),
    Project(
        id='libtiff',
        display='libtiff',
    ),
    Project(
        id='libxml2',
        display='libxml2',
    ),
    Project(
        id='openslide',
        display='OpenSlide',
        primary=True,
    ),
    Project(
        id='openslide-java',
        display='OpenSlide Java',
        primary=True,
    ),
    Project(
        id='pcre2',
        display='PCRE2',
    ),
    Project(
        id='pixman',
        display='pixman',
    ),
    Project(
        id='proxy-libintl',
        display='proxy-libintl',
    ),
    Project(
        id='sqlite3',
        display='SQLite',
    ),
    Project(
        id='uthash',
        display='uthash',
    ),
    Project(
        id='zlib',
        display='zlib',
    ),
)

# gvdb is a copylib bundled with glib, without a stable API
_PROJECTS_IGNORE = {'gvdb'}


def write_project_versions(
    fh: TextIO, env_info: None | dict[str, str] = None
) -> None:
    def line(name: str, version: str, marker: str = '') -> None:
        print(
            '| {:20} | {:53} |'.format(
                f'{marker}{name}{marker}', f'{marker}{version}{marker}'
            ),
            file=fh,
        )

    line('Software', 'Version')
    line('--------', '-------')

    def key(proj: Project) -> tuple[int, str]:
        return (0 if proj.primary else 1, proj.display.lower())

    for proj in sorted(Project.get_enabled(), key=key):
        line(proj.display, proj.version, '**' if proj.primary else '')
    for software, version in sorted((env_info or {}).items()):
        line(software, version, '_')
