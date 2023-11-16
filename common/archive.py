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

from abc import ABC, abstractmethod
from dataclasses import dataclass
import os
from pathlib import Path, PurePath
import re
import tarfile
import time
from types import TracebackType
from typing import BinaryIO, Self
import zipfile


@dataclass
class Member(ABC):
    path: PurePath


@dataclass
class FileMember(Member):
    fh: BinaryIO


@dataclass
class DirMember(Member):
    pass


@dataclass
class SymlinkMember(Member):
    target: PurePath


class ArchiveWriter(ABC):
    def __init__(self, path: Path):
        self.base = PurePath(re.sub('\\.(tar\\.xz|zip)$', '', path.name))
        self._members: dict[PurePath, Member] = {}

    def __enter__(self) -> Self:
        return self

    def __exit__(
        self,
        exc_type: type[BaseException] | None,
        exc_val: BaseException | None,
        exc_tb: TracebackType | None,
    ) -> None:
        self.close()

    @abstractmethod
    def close(self) -> None:
        pass

    def add(self, member: Member) -> None:
        assert member.path not in self._members
        self._members[member.path] = member
        path = member.path.parent
        while path != PurePath('.'):
            parent = self._members.setdefault(path, DirMember(path))
            assert isinstance(parent, DirMember)
            path = path.parent

    def add_tree(self, arcdir: PurePath, path: Path) -> None:
        def walkerr(e: OSError) -> None:
            raise e

        for dpath_str, _, fnames in os.walk(path, onerror=walkerr):
            dpath = Path(dpath_str)
            for fname in fnames:
                self.add(
                    FileMember(
                        arcdir / dpath.relative_to(path.parent) / fname,
                        open(dpath / fname, 'rb'),
                    )
                )


class TarArchiveWriter(ArchiveWriter):
    def __init__(self, fh: BinaryIO):
        super().__init__(Path(fh.name))
        self._tar = tarfile.open(
            fileobj=fh,
            mode='w:xz',
            format=tarfile.PAX_FORMAT,
            preset=9,  # type: ignore[call-arg]
        )
        self._now = int(time.time())

    def close(self) -> None:
        for _, member in sorted(self._members.items()):
            if isinstance(member, FileMember):
                info = self._tar.gettarinfo(
                    arcname=member.path.as_posix(), fileobj=member.fh
                )
                info.mode = info.mode & ~0o022 | 0o644
                info.uid = 0
                info.gid = 0
                info.uname = 'root'
                info.gname = 'root'
                self._tar.addfile(info, member.fh)
            elif isinstance(member, DirMember):
                info = tarfile.TarInfo(member.path.as_posix())
                info.mtime = self._now
                info.mode = 0o755
                info.type = tarfile.DIRTYPE
                info.uname = 'root'
                info.gname = 'root'
                self._tar.addfile(info)
            elif isinstance(member, SymlinkMember):
                info = tarfile.TarInfo(member.path.as_posix())
                info.mtime = self._now
                info.mode = 0o777
                info.type = tarfile.SYMTYPE
                info.linkname = member.target.as_posix()
                info.uname = 'root'
                info.gname = 'root'
                self._tar.addfile(info)
        self._tar.close()


class ZipArchiveWriter(ArchiveWriter):
    def __init__(self, fh: BinaryIO):
        super().__init__(Path(fh.name))
        self._zip = zipfile.ZipFile(
            fh, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9
        )

    def close(self) -> None:
        for _, member in sorted(self._members.items()):
            if isinstance(member, FileMember):
                try:
                    info: str | zipfile.ZipInfo = zipfile.ZipInfo.from_file(
                        member.fh.name, member.path
                    )
                except AttributeError:
                    info = member.path.as_posix()
                self._zip.writestr(info, member.fh.read())
            elif isinstance(member, DirMember):
                self._zip.writestr(member.path.as_posix() + '/', b'')
            elif isinstance(member, SymlinkMember):
                raise Exception('Symlinks not supported in Zip')
        self._zip.close()
