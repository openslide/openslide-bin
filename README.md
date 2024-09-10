# openslide-bin

This is a set of scripts for building OpenSlide and its dependencies for
Windows, macOS, and Linux.  The resulting binaries only depend on the
default platform libraries on each platform: the [UCRT][ucrt] on Windows,
SDK libraries on macOS, and glibc on Linux.

[ucrt]: https://learn.microsoft.com/en-us/cpp/windows/universal-crt-deployment?view=msvc-170

## Building

For Windows and Linux, the build runs in a container image that includes the
necessary tools.  To build for Windows on x64, pull the container image on
Linux or in Windows PowerShell with WSL 2 and use it to run a build:

    docker run -ti --rm -v ${PWD}:/work -w /work \
        ghcr.io/openslide/winbuild-builder ./bintool bdist

Similarly, to build for Linux on aarch64 or x86_64:

    docker run -ti --rm -v ${PWD}:/work -w /work \
        ghcr.io/openslide/linux-builder ./bintool bdist

macOS builds run directly on a macOS system, which can be either Intel or
Apple silicon.  The build will produce a universal binary in either case.
The macOS SDK must be installed.

    ./bintool bdist

## Substitute sources

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

## Adding a new dependency

openslide-bin produces binaries which do not link with shared libraries from
the build environment, except for specific platform libraries on each
supported OS.  To add a library dependency to openslide-bin, you must
configure openslide-bin to build that library itself.

All dependencies must be built with [Meson][], even those that don't natively
support Meson.  For many common libraries, a Meson port is available from
Meson's [wrapdb][].  Otherwise, you'll need to port the library's build
system to Meson and submit the port to wrapdb (or to the upstream project if
its maintainers are interested).

To add a dependency to openslide-bin:

1. Use `meson wrap install` to add the dependency's wrap file from wrapdb
   to the `subprojects` directory.
2. Add the dependency to `_PROJECTS` in `common/software.py`.
   - Test update checking by running `./bintool updates`.  If this complains
     that the project is missing from the Anitya database, ensure [Anitya][]
     maps the project to Meson WrapDB.
3. Modify `deps/meson.build` to invoke the build, in the correct order
   relative to the other dependencies.  Include any necessary build options,
   e.g. disable building command-line tools to reduce build time.

### Common problems

New dependencies sometimes have build bugs that need to be fixed in wrapdb
or upstream.  Common problems include:

1. Libraries dllexporting their public symbols when built as a Windows static
   library.  `dllexport` should only be used when building a dynamic library.
2. Libraries taking an unintended dependency on pthreads.  Many libraries
   use Windows threading primitives on Windows but unconditionally depend on
   `dependency('threads')` in their `meson.build`, thus adding a dependency
   on the pthreads library.  openslide-bin intentionally does not ship a
   pthreads implementation.

Either issue will cause the build or smoke test to fail.  The subproject can
be patched by adding a patch file to the `subprojects/packagefiles`
directory and adding a `diff_files` directive to the subproject's wrap file.

### Submitting a PR

When adding a new dependency to OpenSlide, the corresponding openslide-bin PR
should be be submitted early in the development process, since OpenSlide's CI
will not pass on Windows until the dependency is available in openslide-bin.
The `subproject()` call in `deps/meson.build` should initially be gated
behind `if dev_deps`, causing the new subproject to be omitted from
openslide-bin releases until the feature lands in an OpenSlide release.

All openslide-bin subprojects must use wraps from wrapdb, so new Meson ports
should be submitted there first.  (wrapdb does not expect ports to include
all functionality from the upstream build system.  For example, obscure
options and CPU architectures can be omitted.)  As an exception, wraps for
newly-developed libraries can point directly to an upstream Git commit while
the library is being integrated into OpenSlide.  However, the wrap must be
added to wrapdb before the first OpenSlide release that uses the library.

Similarly, all `diff_files` directives in wrap files must have a comment
linking to a wrapdb PR or upstream PR for the patch.

[Anitya]: https://release-monitoring.org/
[Meson]: https://mesonbuild.com/
[wrapdb]: https://github.com/mesonbuild/wrapdb
