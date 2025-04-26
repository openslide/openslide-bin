#
# openslide-bin - Wrapper for OpenSlide binary build
#
# Copyright (c) 2023 Benjamin Gilbert
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of version 2.1 of the GNU Lesser General Public License
# as published by the Free Software Foundation.
#
# This library is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
# License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this library.  If not, see <http://www.gnu.org/licenses/>.
#

from __future__ import annotations

from ctypes import CDLL, cdll
import importlib.resources as res
import platform


def _load_openslide() -> CDLL:
    if platform.system() == 'Windows':
        name = 'libopenslide-1.dll'
    elif platform.system() == 'Darwin':
        name = 'libopenslide.1.dylib'
    else:
        name = 'libopenslide.so.1'
    try:
        # Python >= 3.9
        with res.as_file(res.files(__name__).joinpath(name)) as path:
            return cdll.LoadLibrary(path.as_posix())
    except AttributeError:
        with res.path(__name__, name) as path:
            return cdll.LoadLibrary(path.as_posix())


libopenslide1 = _load_openslide()
__version__ = '@version@'
