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
from functools import cache, cached_property
from itertools import count
from pathlib import Path
import shutil
import subprocess
import time
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


class AnityaPackageList(TypedDict):
    items: list[AnityaListedPackage]
    items_per_page: int
    page: int
    total_items: int


class AnityaListedPackage(TypedDict):
    distribution: str
    ecosystem: str
    name: str
    project: str
    stable_version: str
    version: str


class AnityaIndividualPackage(TypedDict):
    backend: str
    created_on: float
    ecosystem: str
    homepage: str
    id: int
    name: str
    stable_versions: list[str]
    updated_on: float
    version: str
    version_url: str
    versions: list[str]


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
    # Project ID on release-monitoring.org, for projects not in wrapdb.
    # For projects in wrapdb, configure release-monitoring.org to associate
    # the wrapdb package with the upstream project.
    anitya_id: int | None = None
    primary: bool = False
    remove_dirs: Iterable[str] = ()
    # overrides for default file removals
    keep_files: Iterable[str] = ()

    DIST_REMOVE_FILENAMES = {
        'CMakeLists.txt',
        'configure',
        'configure.ac',
        'ltmain.sh',
        'Makefile',
        'Makefile.am',
        'Makefile.in',
    }
    DIST_REMOVE_SUFFIXES = {'.cmake', '.m4'}

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

    @staticmethod
    def get_all() -> list[Project]:
        return list(_PROJECTS)

    @cached_property
    def wrap(self) -> configparser.RawConfigParser:
        return parse_ini_file(self.wrap_path)

    @property
    def wrap_path(self) -> Path:
        return meson_source_root() / 'subprojects' / f'{self.id}.wrap'

    @property
    def override_path(self) -> Path:
        return meson_source_root() / 'override' / self.id

    @cached_property
    def wrap_dir_name(self) -> str:
        return self.wrap.get('wrap-file', 'directory')

    @cached_property
    def version(self) -> str:
        try:
            # get the wrapdb_version, including the package revision
            ver = self.wrap.get('wrap-file', 'wrapdb_version', fallback=None)
            if not ver:
                # older or non-wrapdb wrap; parse the directory name
                ver = self.wrap_dir_name.split('-')[-1]
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

    @property
    def source_dir(self) -> Path:
        try:
            dirname = self.wrap_dir_name
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

    def prune_dist(self, root: Path) -> None:
        def walkerr(e: OSError) -> None:
            raise e

        projdir = root / 'subprojects' / self.wrap_dir_name
        if not projdir.exists():
            # dev dep omitted from the dist
            return
        for subdir in self.remove_dirs:
            shutil.rmtree(projdir / subdir)
        for dirpath, _, filenames in projdir.walk(on_error=walkerr):
            for filename in filenames:
                path = dirpath / filename
                if path.relative_to(projdir).as_posix() in self.keep_files:
                    continue
                if (
                    path.name in self.DIST_REMOVE_FILENAMES
                    or path.suffix in self.DIST_REMOVE_SUFFIXES
                ):
                    path.unlink()

    @staticmethod
    @cache
    def _get_anitya_versions() -> dict[str, str]:
        import requests

        versions = {}
        items_per_page = 250
        for page in count(1):
            for attempt in range(3):
                if attempt > 0:
                    time.sleep(5)
                resp = requests.get(
                    f'https://release-monitoring.org/api/v2/packages/'
                    f'?distribution=Meson%20WrapDB'
                    f'&items_per_page={items_per_page}'
                    f'&page={page}'
                )
                # retry on gateway timeout
                if resp.status_code != 504:
                    resp.raise_for_status()
                    break
            else:
                raise Exception(
                    'Repeated gateway timeouts when querying Anitya'
                )
            packages: AnityaPackageList = resp.json()
            versions.update(
                {
                    package['name']: package['stable_version']
                    for package in packages['items']
                }
            )
            if len(packages['items']) < items_per_page:
                break
        return versions

    def get_upstream_version(self) -> str:
        import requests

        if self.anitya_id is not None:
            resp = requests.get(
                f'https://release-monitoring.org/api/project/{self.anitya_id}'
            )
            resp.raise_for_status()
            package: AnityaIndividualPackage = resp.json()
            return package['stable_versions'][0]
        else:
            versions = self._get_anitya_versions()
            try:
                return versions[self.id]
            except KeyError:
                raise Exception(f'{self.id} not found in Anitya database')


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
        remove_dirs=['doc', 'perf', 'test'],
    ),
    Project(
        id='gdk-pixbuf',
        display='gdk-pixbuf',
        licenses=['COPYING'],
        remove_dirs=['tests'],
    ),
    Project(
        id='glib',
        display='glib',
        licenses=['COPYING'],
        remove_dirs=['gio/tests', 'glib/tests', 'gobject/tests', 'po'],
        keep_files=[
            'm4macros/glib-2.0.m4',
            'm4macros/glib-gettext.m4',
            'm4macros/gsettings.m4',
        ],
    ),
    Project(
        id='libdicom',
        display='libdicom',
        licenses=['LICENSE'],
        remove_dirs=['doc/html'],
    ),
    Project(
        id='libffi',
        display='libffi',
        licenses=['LICENSE'],
        remove_dirs=['doc', 'testsuite'],
    ),
    Project(
        id='libjpeg-turbo',
        display='libjpeg-turbo',
        licenses=['LICENSE.md', 'README.ijg'],
        remove_dirs=['doc', 'java', 'testimages'],
        keep_files=['simd/CMakeLists.txt'],
    ),
    Project(
        id='libopenjp2',
        display='OpenJPEG',
        licenses=['LICENSE'],
        remove_dirs=[
            'cmake',
            'doc',
            'src/bin',
            'src/lib/openjpip',
            'tests',
            'thirdparty',
            'tools',
            'wrapping',
        ],
    ),
    Project(
        id='libpng',
        display='libpng',
        licenses=['LICENSE'],
        remove_dirs=['ci', 'contrib', 'projects'],
    ),
    Project(
        id='libtiff',
        display='libtiff',
        licenses=['LICENSE.md'],
        remove_dirs=[
            'cmake',
            'config',
            'contrib',
            'doc',
            'test/images',
            'test/refs',
            'tools',
        ],
    ),
    Project(
        id='libxml2',
        display='libxml2',
        licenses=['Copyright'],
        remove_dirs=['fuzz', 'python', 'result', 'test'],
        keep_files=['libxml.m4'],
    ),
    Project(
        id='openslide',
        display='OpenSlide',
        primary=True,
        licenses=['COPYING.LESSER'],
        anitya_id=5600,
        remove_dirs=['doc'],
    ),
    Project(
        id='pcre2',
        display='PCRE2',
        licenses=['LICENCE.md'],
        remove_dirs=['doc', 'testdata'],
    ),
    Project(
        id='pixman',
        display='pixman',
        licenses=['COPYING'],
        remove_dirs=['demos', 'test'],
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
        remove_dirs=['doc', 'tests'],
    ),
    Project(
        id='zlib-ng',
        display='zlib-ng',
        licenses=['LICENSE.md'],
        remove_dirs=['doc', 'test'],
    ),
    Project(
        id='zstd',
        display='Zstandard',
        # Dual-licensed BSD or GPLv2.  Elect BSD.
        licenses=['LICENSE'],
        remove_dirs=['contrib', 'doc', 'programs', 'tests', 'zlibWrapper'],
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
