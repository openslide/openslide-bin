# openslide-bin

This is a set of scripts for building OpenSlide and its dependencies for
Windows, macOS, and Linux.  The resulting binaries only depend on the
default platform libraries on each platform: the [UCRT][ucrt] on Windows,
SDK libraries on macOS, and glibc on Linux.

[ucrt]: https://learn.microsoft.com/en-us/cpp/windows/universal-crt-deployment?view=msvc-170

## Building

For Windows and Linux, the build runs in a container image that includes the
necessary tools.  To build for Windows, pull the container image on Linux or
in Windows PowerShell with WSL 2 and use it to run a build:

    docker run -ti --rm -v ${PWD}:/work -w /work \
        ghcr.io/openslide/winbuild-builder ./bintool bdist

Similarly, to build for Linux:

    docker run -ti --rm -v ${PWD}:/work -w /work \
        ghcr.io/openslide/linux-builder ./bintool bdist

macOS builds run directly on a macOS system, which can be either Intel or
Apple silicon.  The build will produce a universal binary in either case.
The macOS SDK must be installed.

    ./bintool bdist

## Substitute Sources

To override the source tree used to build a project, create a top-level
directory named `override` and place the substitute source tree in a
subdirectory named after the project's ID.  A list of project IDs can be
obtained by running `./bintool projects`.

## bintool subcommands

#### `sdist`

Build `tar.gz` archive containing build system and sources for OpenSlide and
all dependencies.

#### `bdist`

Build Zip or `tar.xz` archive containing OpenSlide binaries.

#### `smoke`

Manually run a smoke test on a `bdist` archive.  `bdist` automatically runs
smoke tests after Linux and macOS builds, but not after Windows builds.

#### `versions`

Produce a composite `VERSIONS.md` listing all project versions from one or
more bdist archives.

#### `clean`

Delete build and binary directories, but not downloaded tarballs.

#### `updates`

Check for new releases of component projects.

#### `version`

Report the version number that will be used in archive file names.

#### `projects`

Report the IDs and display names of all component projects.
