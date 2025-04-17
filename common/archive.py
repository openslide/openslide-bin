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
from base64 import urlsafe_b64encode
from collections.abc import Iterable, Iterator, Sequence
from contextlib import ExitStack, contextmanager
import copy
from dataclasses import dataclass
from functools import cached_property
from hashlib import sha256
from io import BytesIO
from itertools import zip_longest
from pathlib import Path, PurePath
import re
import tarfile
import tempfile
import time
from types import TracebackType
from typing import BinaryIO, Self, cast
import zipfile


@dataclass
class Member(ABC):
    path: PurePath

    @property
    def relpath(self) -> PurePath:
        return PurePath(*self.path.parts[1:])

    def with_base(self, base: PurePath) -> Member:
        member = copy.copy(self)
        member.path = base / member.relpath
        return member


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
        self.base = _path_base(path)
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

        for dpath, _, fnames in path.walk(on_error=walkerr):
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
            preset=9,
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
        self._zip = zipfile.ZipFile(fh, 'w')

    def close(self) -> None:
        for _, member in sorted(self._members.items()):
            if isinstance(member, FileMember):
                try:
                    info: str | zipfile.ZipInfo = zipfile.ZipInfo.from_file(
                        member.fh.name, member.path
                    )
                except AttributeError:
                    info = member.path.as_posix()
                self._zip.writestr(
                    info,
                    member.fh.read(),
                    compress_type=zipfile.ZIP_DEFLATED,
                    compresslevel=9,
                )
            elif isinstance(member, DirMember):
                self._zip.writestr(member.path.as_posix() + '/', b'')
            elif isinstance(member, SymlinkMember):
                raise Exception('Symlinks not supported in Zip')
        self._zip.close()


class WheelWriter(ZipArchiveWriter):
    def __init__(self, fh: BinaryIO):
        (
            self.package,
            self.version,
            self.python,
            self.abi,
            self.platform,
        ) = Path(fh.name).stem.split('-')
        self.tag = f'{self.python}-{self.abi}-{self.platform}'
        self.datadir = PurePath(self.package)
        self.metadir = PurePath(f'{self.package}-{self.version}.dist-info')
        self._records: list[str] = []
        super().__init__(fh)

    def add(self, member: Member) -> None:
        if isinstance(member, FileMember):
            contents = member.fh.read()
            member.fh.seek(0)
            hash = (
                urlsafe_b64encode(sha256(contents).digest())
                .decode()
                .rstrip('=')
            )
            self._records.append(
                f'{member.path.as_posix()},sha256={hash},{len(contents)}'
            )
        super().add(member)

    def __exit__(
        self,
        exc_type: type[BaseException] | None,
        exc_val: BaseException | None,
        exc_tb: TracebackType | None,
    ) -> None:
        record_path = self.metadir / 'RECORD'
        self._records.append(f'{record_path.as_posix()},,')
        record_data = '\n'.join(sorted(self._records)) + '\n'
        super().add(FileMember(record_path, BytesIO(record_data.encode())))
        return super().__exit__(exc_type, exc_val, exc_tb)


class ArchiveReader(ABC):
    def __init__(self, path: Path):
        self.base = _path_base(path)
        self._tempdir = tempfile.TemporaryDirectory(prefix='openslide-bin-')
        self._dir = Path(self._tempdir.name)

    @classmethod
    @contextmanager
    def group(cls, fhs: Iterable[BinaryIO]) -> Iterator[Iterator[MemberSet]]:
        with ExitStack() as stack:
            readers = [
                # mypy thinks we're initializing this ABC, not a subclass
                stack.enter_context(cls(fh))  # type: ignore[arg-type]
                for fh in fhs
            ]
            yield (MemberSet(members) for members in zip_longest(*readers))

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
        self._tempdir.cleanup()

    @abstractmethod
    def __iter__(self) -> Iterator[Member]:
        pass


class TarArchiveReader(ArchiveReader):
    def __init__(self, fh: BinaryIO):
        super().__init__(Path(fh.name))
        self._tar = tarfile.open(fileobj=fh)
        self._tar.extraction_filter = tarfile.data_filter

    def close(self) -> None:
        self._tar.close()
        super().close()

    def __iter__(self) -> Iterator[Member]:
        while True:
            info = self._tar.next()
            if info is None:
                return
            path = PurePath(info.name)
            if info.type == tarfile.DIRTYPE:
                yield DirMember(path)
            elif info.type == tarfile.REGTYPE:
                self._tar.extract(info, self._dir)
                yield FileMember(path, open(self._dir / path, 'rb'))
            elif info.type == tarfile.SYMTYPE:
                yield SymlinkMember(path, PurePath(info.linkname))
            else:
                raise Exception(
                    f'Unsupported member type: {info.type.decode()}'
                )


class ZipArchiveReader(ArchiveReader):
    def __init__(self, fh: BinaryIO):
        super().__init__(Path(fh.name))
        self._zip = zipfile.ZipFile(fh)

    def close(self) -> None:
        self._zip.close()
        super().close()

    def __iter__(self) -> Iterator[Member]:
        for info in self._zip.infolist():
            path = PurePath(info.filename)
            if info.is_dir():
                yield DirMember(path)
            else:
                yield FileMember(
                    path, open(self._zip.extract(info, self._dir), 'rb')
                )


class MemberSet:
    def __init__(self, members: Sequence[Member | None]):
        if not all(members):
            raise Exception('Missing member in one or more archives')
        self.members = cast(Sequence[Member], members)

    def __getitem__(self, idx: int) -> Member:
        return self.members[idx]

    def __iter__(self) -> Iterator[Member]:
        return iter(self.members)

    @property
    def relpaths(self) -> Sequence[PurePath]:
        return [member.relpath for member in self]

    @cached_property
    def datas(self) -> Sequence[bytes]:
        ret = []
        for member in self:
            if not isinstance(member, FileMember):
                raise Exception('Member is not a file')
            ret.append(member.fh.read())
            member.fh.seek(0)
        return ret


def _path_base(path: Path) -> PurePath:
    return PurePath(re.sub('\\.(tar\\.xz|zip)$', '', path.name))
