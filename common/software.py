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

from abc import ABC
from collections.abc import Callable, Iterable
import configparser
from dataclasses import dataclass
from functools import cached_property
from pathlib import Path
import shutil
import subprocess
from typing import Literal, TextIO, TypedDict

from .meson import meson_introspect, meson_source_root, parse_ini_file


class Infos(TypedDict):
    versions: list[Info]


class Info(TypedDict):
    id: str
    display: str
    version: str
    type: SoftwareType


SoftwareType = Literal['primary', 'dependency', 'tool']


@dataclass
class Software(ABC):
    id: str
    display: str

    @property
    def info(self) -> Info:
        if isinstance(self, Tool):
            typ: SoftwareType = 'tool'
        elif isinstance(self, Project) and self.primary:
            typ = 'primary'
        else:
            typ = 'dependency'
        return {
            'id': self.id,
            'display': self.display,
            # non-abstract subclasses have a version field or property
            'version': self.version,  # type: ignore[attr-defined]
            'type': typ,
        }


@dataclass
class Tool(Software):
    version: str


@dataclass
class Project(Software):
    licenses: Iterable[str | Callable[[Project], tuple[str, str]]]
    primary: bool = False

    @staticmethod
    def get(id: str) -> Project:
        for p in _PROJECTS:
            if p.id == id:
                return p
        raise KeyError

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

    def write_licenses(self, dir: Path) -> None:
        dir.mkdir(parents=True)
        for license in self.licenses:
            if callable(license):
                name, contents = license(self)
                with open(dir / name, 'w') as fh:
                    fh.write(contents)
            else:
                shutil.copy2(
                    self.source_dir / license, dir / Path(license).name
                )


def _sqlite3_license(proj: Project) -> tuple[str, str]:
    '''Extract public-domain dedication from the top of sqlite3.h'''
    with open(proj.source_dir / 'sqlite3.h') as fh:
        ret: list[str] = []
        for line in fh:
            if not line.startswith('**'):
                continue
            if line.startswith('*****'):
                return 'PUBLIC-DOMAIN.txt', ''.join(ret)
            ret.append(line)
    raise Exception("Couldn't parse license header")


_PROJECTS = (
    Project(
        id='cairo',
        display='cairo',
        licenses=['COPYING', 'COPYING-LGPL-2.1', 'COPYING-MPL-1.1'],
    ),
    Project(
        id='gdk-pixbuf',
        display='gdk-pixbuf',
        licenses=['COPYING'],
    ),
    Project(
        id='glib',
        display='glib',
        licenses=['COPYING'],
    ),
    Project(
        id='libdicom',
        display='libdicom',
        licenses=['LICENSE'],
    ),
    Project(
        id='libffi',
        display='libffi',
        licenses=['LICENSE'],
    ),
    Project(
        id='libjpeg-turbo',
        display='libjpeg-turbo',
        licenses=['LICENSE.md', 'README.ijg'],
    ),
    Project(
        id='libopenjp2',
        display='OpenJPEG',
        licenses=['LICENSE'],
    ),
    Project(
        id='libpng',
        display='libpng',
        licenses=['LICENSE'],
    ),
    Project(
        id='libtiff',
        display='libtiff',
        licenses=['LICENSE.md'],
    ),
    Project(
        id='libxml2',
        display='libxml2',
        licenses=['Copyright'],
    ),
    Project(
        id='openslide',
        display='OpenSlide',
        primary=True,
        licenses=['COPYING.LESSER'],
    ),
    Project(
        id='openslide-java',
        display='OpenSlide Java',
        primary=True,
        licenses=['COPYING.LESSER'],
    ),
    Project(
        id='pcre2',
        display='PCRE2',
        licenses=['LICENCE'],
    ),
    Project(
        id='pixman',
        display='pixman',
        licenses=['COPYING'],
    ),
    Project(
        id='proxy-libintl',
        display='proxy-libintl',
        licenses=['COPYING'],
    ),
    Project(
        id='sqlite3',
        display='SQLite',
        licenses=[_sqlite3_license],
    ),
    Project(
        id='uthash',
        display='uthash',
        licenses=['LICENSE'],
    ),
    Project(
        id='zlib',
        display='zlib',
        licenses=['README'],
    ),
)

# gvdb is a copylib bundled with glib, without a stable API
_PROJECTS_IGNORE = {'gvdb'}


def _sorted_infos(infos: list[Info]) -> list[Info]:
    def key(info: Info) -> tuple[int, str]:
        return (typ_map[info['type']], info['display'].lower())

    typ_map = {'primary': 0, 'dependency': 1, 'tool': 2}
    return sorted(infos, key=key)


def get_software_info(softwares: Iterable[Software]) -> Infos:
    return {'versions': _sorted_infos([sw.info for sw in softwares])}


def write_version_markdown(fh: TextIO, infos: Infos) -> None:
    def line(name: str, version: str, marker: str = '') -> None:
        print(
            '| {:21} | {:52} |'.format(
                f'{marker}{name}{marker}', f'{marker}{version}{marker}'
            ),
            file=fh,
        )

    line('Software', 'Version')
    line('--------', '-------')
    typ_map = {'primary': '**', 'dependency': '', 'tool': '_'}
    for info in _sorted_infos(infos['versions']):
        line(info['display'], info['version'], typ_map[info['type']])
