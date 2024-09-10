# openslide-bin

[OpenSlide Python][] requires a copy of [OpenSlide][].  You could install
it from your package manager, or you could download binaries from the
OpenSlide website.  Either choice might be inconvenient, and depending on
your package manager, it might get you an old version of OpenSlide.

[openslide-bin][] is a pip-installable, self-contained build of OpenSlide
for Linux, macOS, and Windows.  It's built by the OpenSlide maintainers,
ships the same binaries as the OpenSlide website, and has no dependencies
you don't already have on your system.  And it always has the latest version
of OpenSlide.

[OpenSlide Python]: https://pypi.org/project/openslide-python/
[OpenSlide]: https://openslide.org/
[openslide-bin]: https://github.com/openslide/openslide-bin/

## Installing

Install with `pip install openslide-bin`.  OpenSlide Python ≥ 1.4.0 will
automatically find openslide-bin and use it.

openslide-bin is available for Python 3.8+ on the following platforms:

- Linux aarch64 and x86_64 with glibc 2.28+ (Debian, Fedora, RHEL 8+,
  Ubuntu, many others)
- macOS 11+ (arm64 and x86_64)
- Windows 10+ and Windows Server 2016+ (x64)

pip older than 20.3 cannot install openslide-bin, claiming that it `is not a
supported wheel on this platform`.  On platforms with these versions of pip
(RHEL 8 and Ubuntu 20.04), upgrade pip first with `pip install --upgrade
pip`.

## Using

Use OpenSlide via [OpenSlide Python][].  The OpenSlide Python
[API documentation][] will get you started.

[API documentation]: https://openslide.org/api/python/

## Building from source

You should probably [build OpenSlide from source][openslide-build] instead.

The wheels are built by a [custom script][] that runs [Meson][] in builder
containers.  The source tarball includes all the source code and scripts,
and the wheels are built directly from the tarball, but the build cannot be
invoked from a [PEP 517][] frontend like `build` or `pip`.  If wheels are
not available for your system, building openslide-bin from source is not
likely to help, and you'll likely have better luck installing OpenSlide from
source directly.

[openslide-build]: https://github.com/openslide/openslide/#compiling
[custom script]: https://github.com/openslide/openslide-bin/#readme
[Meson]: https://mesonbuild.com/
[PEP 517]: https://peps.python.org/pep-0517/

## License

OpenSlide and openslide-bin are released under the terms of the
[GNU Lesser General Public License, version 2.1][lgpl].

openslide-bin includes components released under the LGPL 2.1 and other
compatible licenses.  A complete set of component licenses is installed in
the `licenses` subdirectory of openslide-bin's `dist-info` metadata.

OpenSlide and openslide-bin are distributed in the hope that they will be
useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
General Public License for more details.

[lgpl]: https://openslide.org/license/
