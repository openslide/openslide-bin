# openslide-bin

This is a set of scripts for building OpenSlide for Windows, including all
of its dependencies, using MinGW-w64.

## Building

The `builder/windows` directory defines a container image with the
dependencies needed to run the build script.  On Linux, or in Windows
PowerShell with WSL 2, you can pull the container image and use it to run a
build:

    docker run -ti --rm -v ${PWD}:/work -w /work \
        ghcr.io/openslide/winbuild-builder ./build.sh bdist

## Substitute Sources

To override the source tree used to build a package, create a top-level
directory named `override` and place the substitute source tree in a
subdirectory named after the package's shortname.  A list of shortnames
can be obtained by running `build.sh` with no arguments.

## build.sh Subcommands

#### `sdist`

Build `tar.gz` file containing build system and sources for OpenSlide and
all dependencies.

#### `bdist`

Build Zip file containing binaries of OpenSlide and all dependencies.

#### `clean`

Delete build and binary directories, but not downloaded tarballs.  If one
or more package shortnames is specified, delete only the build artifacts for
those packages in the specified bitness.

#### `updates`

Check for new releases of software packages.

#### `version`

Report the version number that will be used in archive file names.

## Options

These must be specified before the subcommand.

#### `-j<n>`

Parallel build with the specified parallelism.

#### `-s<suffix>`

Append `suffix` to the OpenSlide version string.

#### `-w`

Treat OpenSlide and OpenSlide Java build warnings as errors.

#### `-x<suffix>`

Set version number suffix in archive file names to `suffix`.
