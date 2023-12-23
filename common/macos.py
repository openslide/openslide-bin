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

from collections.abc import Iterable, Sequence
import os
from pathlib import Path
import subprocess
from typing import Any


def merge_macho(paths: Sequence[Path], outdir: Path) -> Path:
    outpath = outdir / paths[0].name
    args: list[str | Path] = [
        os.environ.get('LIPO', 'lipo'),
        '-create',
        '-output',
        outpath,
    ]
    args.extend(paths)
    subprocess.check_call(args)
    return outpath


def all_equal(items: Iterable[Any]) -> bool:
    it = iter(items)
    first = next(it)
    return all(i == first for i in it)
