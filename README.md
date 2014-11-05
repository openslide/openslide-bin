This is a set of scripts for building OpenSlide for Windows, including all
of its dependencies, using MinGW-w64.

Cross-compiling from Linux
--------------------------

You will need:

- MinGW-w64 gcc and g++ for the target architecture (`i686` or `x86_64`)
- NASM
- OpenJDK
- Apache Ant
- CMake
- gettext utility programs
- glib2 utility programs
- Native gcc and binutils for your build platform
- The GNU Classpath version of `jni.h` must be installed.  (On Fedora this
  is in the `libgcj-devel` package.)

Then:

    ./build.sh bdist

Building natively on Windows
----------------------------

### One-time setup

1.  Install a JDK.

2.  Install Cygwin, accepting the default set of packages.  Make note of
    the location of the installer EXE.

3.  Launch a Cygwin shell and navigate to the openslide-winbuild directory.

4.  Execute:

        ./build.sh setup /path/to/cygwin/setup.exe

### Building

    ./build.sh bdist

Note that cross-compiling is *much* faster than compiling natively.

### Troubleshooting

The build will fail if the path to the openslide-winbuild directory
contains spaces.

If the build randomly fails complaining that `fork()` failed due to a DLL
address mismatch, follow the instructions [here][1].

[1]: http://cygwin.wikia.com/wiki/Rebaseall

Substitute Sources
------------------

To override the source tree used to build a package, create a top-level
directory named `override` and place the substitute source tree in a
subdirectory named after the package's shortname.  A list of shortnames
can be obtained by running `build.sh` with no arguments.

build.sh Subcommands
--------------------

#### `setup`

Configure Cygwin environment.  Only useful on Windows.  The path to Cygwin's
`setup.exe` must be specified as an argument.

#### `sdist`

Build Zip file containing build system and sources for OpenSlide and all
dependencies.

#### `bdist`

Build Zip file containing binaries of OpenSlide and all dependencies.

#### `clean`

Delete build and binary directories, but not downloaded tarballs.  If one
or more package shortnames is specified, delete only the build artifacts for
those packages in the specified bitness.

#### `updates`

Check for new releases of software packages.

Options
-------

These must be specified before the subcommand.

#### `-j<n>`

Parallel build with the specified parallelism.

#### `-m{32|64}`

Select 32-bit or 64-bit build (default: 32).

#### `-p<pkgver>`

Set package version string in Zip file names to `pkgver`.

#### `-s<suffix>`

Append `suffix` to the OpenSlide version string.
