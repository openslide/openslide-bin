# Notable Changes in openslide-bin

## Version 4.0.0.8, 2025-04-27

* Update many dependencies


## Version 4.0.0.6, 2024-09-29

* Switch from zlib to zlib-ng
* Export type hints from Python package
* Reduce size of source archive
* Update various dependencies


## Version 4.0.0.5, 2024-09-10

* Add Linux aarch64 build
* Update cairo


## Version 4.0.0.4, 2024-09-01

* Update many dependencies


## Version 4.0.0.3, 2024-05-04

* Remove OpenSlide Java, which no longer has a platform-dependent component
* Update SQLite


## Version 4.0.0.2, 2024-03-29

* Add Linux and macOS builds
* Add [Python package][py] with compiled library for OpenSlide Python ≥ 1.4.0
* Drop 32-bit Windows build
* Update OpenSlide Java to 0.12.4
* Update many dependencies
* Add `CHANGELOG.md` to source and binary archives
* Add `versions.json` to binary archives
* Rename project from openslide-winbuild to openslide-bin
* Change version number to OpenSlide version plus openslide-bin build number
* Restructure filenames of source and binary archives
* Switch source archive from Zip to `tar.gz`
* Rewrite build scripts

[py]: https://pypi.org/project/openslide-bin/


## Windows build 20231011

* Update OpenSlide to 4.0.0
* Integrate all dependencies into the OpenSlide DLL
* Replace the separate command-line tools with `slidetool`
* Switch from MSVCRT to the [Universal C Runtime][ucrt] (UCRT)

[ucrt]: https://learn.microsoft.com/en-us/cpp/windows/universal-crt-deployment


## Windows build 20230414

* Integrate most dependencies into the OpenSlide DLL
* Update various dependencies


## Windows build 20221217

* Update OpenSlide Java to 0.12.3
* Update several dependencies


## Windows build 20221111

* Update many dependencies


## Windows build 20220811

* Fix crashes in the 64-bit binaries when reading invalid JPEG or PNG images


## Windows build 20220806

* Update the compiler and all dependencies to current versions


## Windows build 20171122

* Update OpenSlide Java to 0.12.2
* Update many dependencies


## Windows build 20160717

* Update OpenJPEG to version 2.1.1


## Windows build 20160612

* Fix crashes in the 32-bit binaries when called from code compiled with MSVC


## Windows build 20150527

* Fix crashes in the 32-bit binaries


## Windows build 20150420

* Update OpenSlide to 3.4.1
* Update OpenSlide Java to 0.12.1
* Add separate debug symbols for all binaries


## Windows build 20140125

* Update OpenSlide to 3.4.0
* Update OpenSlide Java to 0.12.0


## Windows build 20130727

* Prevent libtiff from opening a dialog box upon encountering an invalid TIFF
  file


## Windows build 20130413

* Update OpenSlide to 3.3.3
* Fix a runtime crash when linked with `/OPT:REF`


## Windows build 20121201

* Update OpenSlide to 3.3.2
* Fix a serious thread safety issue


## Windows build 20121014

* Update OpenSlide to 3.3.1


## Windows build 20120908

* Update OpenSlide to 3.3.0
* Update OpenSlide Java to 0.11.0


## Windows build 20120802

* Initial release with OpenSlide 3.2.6 and OpenSlide Java 0.10.0
