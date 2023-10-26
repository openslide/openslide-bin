# openslide-crossplatform-build

This is a set of scripts for building OpenSlide for Windows, Mac, Linux (x86_64)
and Mac (aarch64) including all of its dependencies using MinGW-w64, gcc or
clang depending on the target platform.

## Building

The `builder` directory defines a container image with the dependencies
needed to run the build script.  To pull the container image and use it to
run a build:

    docker run -ti --rm -v $PWD:/work -w /work \
        ghcr.io/openslide/winbuild-builder ./build.sh bdist

## Substitute Sources

To override the source tree used to build a package, create a top-level
directory named `override` and place the substitute source tree in a
subdirectory named after the package's shortname.  A list of shortnames
can be obtained by running `build.sh` with no arguments.

## build.sh Subcommands

### `sdist`

Build Zip file containing build system and sources for OpenSlide and all
dependencies.

### `bdist`

Build Zip file containing binaries of OpenSlide and all dependencies.

### `clean`

Delete build and binary directories, but not downloaded tarballs.  If one
or more package shortnames is specified, delete only the build artifacts for
those packages in the specified bitness.

### `updates`

Check for new releases of software packages.

## Options

These must be specified before the subcommand.

### `-j<n>`

Parallel build with the specified parallelism.

### `-n`

Perform native build instead of a cross build (default: cross). Mainly useful for
building mac binaries natively e.g. on a github action runner.

### `-m{win-i686|win-x86_64|linux-x86_64|mac-x86_64}`

Select architecture to target, currently i686 (x86 32-bit) or x86_64 (x86 64-bit) build (default: i686).

### `-p<pkgver>`

Set package version string in Zip file names to `pkgver`.

### `-s<suffix>`

Append `suffix` to the OpenSlide version string.

### `-w`

Treat OpenSlide and OpenSlide Java build warnings as errors.
