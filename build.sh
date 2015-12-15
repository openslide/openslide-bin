#!/bin/bash
#
# A script for building OpenSlide and its dependencies for Windows
#
# Copyright (c) 2011-2015 Carnegie Mellon University
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

set -eE

packages="configguess zlib png jpeg tiff openjpeg iconv gettext ffi glib gdkpixbuf pixman cairo xml sqlite openslide openslidejava"

# Tool configuration for Cygwin
cygtools="wget zip pkg-config make cmake mingw64-i686-gcc-g++ mingw64-x86_64-gcc-g++ binutils nasm gettext-devel libglib2.0-devel"
ant_ver="1.9.6"
ant_url="http://archive.apache.org/dist/ant/binaries/apache-ant-${ant_ver}-bin.tar.bz2"
ant_build="apache-ant-${ant_ver}"  # not actually a source tree
ant_upurl="http://archive.apache.org/dist/ant/binaries/"
ant_upregex="apache-ant-([0-9.]+)-bin"

# Package display names.  Missing packages are not included in VERSIONS.txt.
zlib_name="zlib"
png_name="libpng"
jpeg_name="libjpeg-turbo"
tiff_name="libtiff"
openjpeg_name="OpenJPEG"
iconv_name="win-iconv"
gettext_name="gettext"
ffi_name="libffi"
glib_name="glib"
gdkpixbuf_name="gdk-pixbuf"
pixman_name="pixman"
cairo_name="cairo"
xml_name="libxml2"
sqlite_name="SQLite"
openslide_name="OpenSlide"
openslidejava_name="OpenSlide Java"

# Package versions
configguess_ver="47681e2a"
zlib_ver="1.2.8"
png_ver="1.6.19"
jpeg_ver="1.4.2"
tiff_ver="4.0.6"
openjpeg_ver="2.1.0"
iconv_ver="0.0.6"
gettext_ver="0.19.6"
ffi_ver="3.2.1"
glib_basever="2.46"
glib_ver="${glib_basever}.2"
gdkpixbuf_basever="2.33"
gdkpixbuf_ver="${gdkpixbuf_basever}.2"
pixman_ver="0.32.8"
cairo_ver="1.14.6"
xml_ver="2.9.3"
sqlite_year="2015"
sqlite_ver="3.9.2"
sqlite_vernum="3090200"
openslide_ver="3.4.1"
openslidejava_ver="0.12.1"

# Tarball URLs
configguess_url="http://git.savannah.gnu.org/cgit/config.git/plain/config.guess?id=${configguess_ver}"
zlib_url="http://prdownloads.sourceforge.net/libpng/zlib-${zlib_ver}.tar.xz"
png_url="http://prdownloads.sourceforge.net/libpng/libpng-${png_ver}.tar.xz"
jpeg_url="http://prdownloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-${jpeg_ver}.tar.gz"
tiff_url="http://download.osgeo.org/libtiff/tiff-${tiff_ver}.tar.gz"
openjpeg_url="http://prdownloads.sourceforge.net/openjpeg.mirror/openjpeg-${openjpeg_ver}.tar.gz"
iconv_url="https://win-iconv.googlecode.com/files/win-iconv-${iconv_ver}.tar.bz2"
gettext_url="http://ftp.gnu.org/pub/gnu/gettext/gettext-${gettext_ver}.tar.xz"
ffi_url="ftp://sourceware.org/pub/libffi/libffi-${ffi_ver}.tar.gz"
glib_url="http://ftp.gnome.org/pub/gnome/sources/glib/${glib_basever}/glib-${glib_ver}.tar.xz"
gdkpixbuf_url="http://ftp.gnome.org/pub/gnome/sources/gdk-pixbuf/${gdkpixbuf_basever}/gdk-pixbuf-${gdkpixbuf_ver}.tar.xz"
pixman_url="http://cairographics.org/releases/pixman-${pixman_ver}.tar.gz"
cairo_url="http://cairographics.org/releases/cairo-${cairo_ver}.tar.xz"
xml_url="ftp://xmlsoft.org/libxml2/libxml2-${xml_ver}.tar.gz"
sqlite_url="http://www.sqlite.org/${sqlite_year}/sqlite-autoconf-${sqlite_vernum}.tar.gz"
openslide_url="https://github.com/openslide/openslide/releases/download/v${openslide_ver}/openslide-${openslide_ver}.tar.xz"
openslidejava_url="https://github.com/openslide/openslide-java/releases/download/v${openslidejava_ver}/openslide-java-${openslidejava_ver}.tar.xz"

# Unpacked source trees
zlib_build="zlib-${zlib_ver}"
png_build="libpng-${png_ver}"
jpeg_build="libjpeg-turbo-${jpeg_ver}"
tiff_build="tiff-${tiff_ver}"
openjpeg_build="openjpeg-${openjpeg_ver}"
iconv_build="win-iconv-${iconv_ver}"
gettext_build="gettext-${gettext_ver}/gettext-runtime"
ffi_build="libffi-${ffi_ver}"
glib_build="glib-${glib_ver}"
gdkpixbuf_build="gdk-pixbuf-${gdkpixbuf_ver}"
pixman_build="pixman-${pixman_ver}"
cairo_build="cairo-${cairo_ver}"
xml_build="libxml2-${xml_ver}"
sqlite_build="sqlite-autoconf-${sqlite_vernum}"
openslide_build="openslide-${openslide_ver}"
openslidejava_build="openslide-java-${openslidejava_ver}"

# Locations of license files within the source tree
zlib_licenses="README"
png_licenses="png.h"  # !!!
jpeg_licenses="README README-turbo.txt"
tiff_licenses="COPYRIGHT"
openjpeg_licenses="LICENSE"
iconv_licenses="readme.txt"
gettext_licenses="COPYING intl/COPYING.LIB"
ffi_licenses="LICENSE"
glib_licenses="COPYING"
gdkpixbuf_licenses="COPYING"
pixman_licenses="COPYING"
cairo_licenses="COPYING COPYING-LGPL-2.1 COPYING-MPL-1.1"
xml_licenses="COPYING"
sqlite_licenses="PUBLIC-DOMAIN.txt"
openslide_licenses="LICENSE.txt lgpl-2.1.txt"
openslidejava_licenses="LICENSE.txt lgpl-2.1.txt"

# Build dependencies
zlib_dependencies=""
png_dependencies="zlib"
jpeg_dependencies=""
tiff_dependencies="zlib jpeg"
openjpeg_dependencies="png tiff"
iconv_dependencies=""
gettext_dependencies="iconv"
ffi_dependencies=""
glib_dependencies="zlib iconv gettext ffi"
gdkpixbuf_dependencies="png jpeg tiff glib"
pixman_dependencies=""
cairo_dependencies="zlib png pixman"
xml_dependencies="zlib iconv"
sqlite_dependencies=""
openslide_dependencies="png jpeg tiff openjpeg glib gdkpixbuf cairo xml sqlite"
openslidejava_dependencies="openslide"

# Build artifacts
zlib_artifacts="zlib1.dll"
png_artifacts="libpng16-16.dll"
jpeg_artifacts="libjpeg-62.dll"
tiff_artifacts="libtiff-5.dll"
openjpeg_artifacts="libopenjp2.dll"
iconv_artifacts="iconv.dll"
gettext_artifacts="libintl-8.dll"
ffi_artifacts="libffi-6.dll"
glib_artifacts="libglib-2.0-0.dll libgthread-2.0-0.dll libgobject-2.0-0.dll libgio-2.0-0.dll libgmodule-2.0-0.dll"
gdkpixbuf_artifacts="libgdk_pixbuf-2.0-0.dll"
pixman_artifacts="libpixman-1-0.dll"
cairo_artifacts="libcairo-2.dll"
xml_artifacts="libxml2-2.dll"
sqlite_artifacts="libsqlite3-0.dll"
openslide_artifacts="libopenslide-0.dll openslide-quickhash1sum.exe openslide-show-properties.exe openslide-write-png.exe"
openslidejava_artifacts="openslide-jni.dll openslide.jar"

# Update-checking URLs
zlib_upurl="http://zlib.net/"
png_upurl="http://www.libpng.org/pub/png/libpng.html"
jpeg_upurl="http://sourceforge.net/projects/libjpeg-turbo/files/"
tiff_upurl="http://download.osgeo.org/libtiff/"
openjpeg_upurl="http://sourceforge.net/projects/openjpeg.mirror/files/"
iconv_upurl="http://win-iconv.googlecode.com/svn/tags/"
gettext_upurl="http://ftp.gnu.org/pub/gnu/gettext/"
ffi_upurl="ftp://sourceware.org/pub/libffi/"
glib_upurl="https://git.gnome.org/browse/glib/refs/"
gdkpixbuf_upurl="https://git.gnome.org/browse/gdk-pixbuf/refs/"
pixman_upurl="http://cairographics.org/releases/"
cairo_upurl="http://cairographics.org/releases/"
xml_upurl="ftp://xmlsoft.org/libxml2/"
sqlite_upurl="http://sqlite.org/changes.html"
openslide_upurl="https://github.com/openslide/openslide/tags"
openslidejava_upurl="https://github.com/openslide/openslide-java/tags"

# Update-checking regexes
zlib_upregex="source code, version ([0-9.]+)"
png_upregex="libpng-([0-9.]+)-README.txt"
jpeg_upregex="files/([0-9.]+)/"
tiff_upregex="tiff-([0-9.]+)\.tar"
openjpeg_upregex="files/([0-9.]+)/"
iconv_upregex=">([0-9.]+)/<"
gettext_upregex="gettext-([0-9.]+)\.tar"
ffi_upregex="libffi-([0-9.]+)\.tar"
glib_upregex="snapshot/glib-([0-9]+\.[0-9]*[02468]\.[0-9]+)\.tar"
# Exclude 2.90.x
gdkpixbuf_upregex="snapshot/gdk-pixbuf-2\.90.*|.*snapshot/gdk-pixbuf-([0-9.]+)\.tar"
pixman_upregex="pixman-([0-9.]+)\.tar"
cairo_upregex="\"cairo-([0-9.]+)\.tar"
xml_upregex="libxml2-([0-9.]+)\.tar"
sqlite_upregex="[0-9]{4}-[0-9]{2}-[0-9]{2} \(([0-9.]+)\)"
openslide_upregex="archive/v([0-9.]+)\.tar"
# Exclude old v1.0.0 tag
openslidejava_upregex="archive/v1\.0\.0\.tar.*|.*archive/v([0-9.]+)\.tar"

# Helper script paths
configguess_path="tar/config.guess-${configguess_ver}"

# wget standard options
# On Cygwin, wget 1.16.1 with IRI support enabled will incorrectly convert
# "%2B" in redirect URLs to "+", but only when not launched from a Cygwin
# shell.  This breaks the S3 signed URLs returned by GitHub when fetching
# a release artifact.
# http://lists.gnu.org/archive/html/bug-wget/2015-01/msg00004.html
wget="wget -q --no-iri"


expand() {
    # Print the contents of the named variable
    # $1  = the name of the variable to expand
    echo "${!1}"
}

tarpath() {
    # Print the tarball path for the specified package
    # $1  = the name of the program
    local path xzpath
    if [ "$1" = "configguess" ] ; then
        # Can't be derived from URL
        echo "$configguess_path"
    else
        path="tar/$(basename $(expand ${1}_url))"
        xzpath="${path/%.gz/.xz}"
        # Prefer tarball recompressed with xz, if available
        if [ -e "$xzpath" ] ; then
            echo "$xzpath"
        else
            echo "$path"
        fi
    fi
}

setup_cygwin() {
    # Install necessary tools for Cygwin builds.
    # $1  = path to Cygwin setup.exe

    # Install cygwin packages
    "$1" -q -P "${cygtools// /,}" >/dev/null

    # Wait for cygwin installer
    while [ ! -x /usr/bin/wget ] ; do
        sleep 1
    done

    # Install ant binary distribution in /opt/ant
    if [ ! -e /opt/ant ] ; then
        fetch ant
        echo "Installing ant..."
        mkdir -p /opt
        tar xf "$(tarpath ant)" -C /opt
        mv "/opt/${ant_build}" /opt/ant
    fi
}

fetch() {
    # Fetch the specified package
    # $1  = package shortname
    local url
    url="$(expand ${1}_url)"
    mkdir -p tar
    if [ ! -e "$(tarpath $1)" ] ; then
        echo "Fetching ${1}..."
        if [ "$1" = "configguess" ] ; then
            # config.guess is special; we have to rename the saved file
            ${wget} -O "$configguess_path" "$url"
        else
            ${wget} -P tar "$url"
        fi
    fi
}

unpack() {
    # Remove the package build directory and re-unpack it
    # $1  = package shortname
    local path
    fetch "${1}"
    mkdir -p "${build}"
    path="${build}/$(expand ${1}_build)"
    if [ -e "override/${1}" ] ; then
        echo "Unpacking ${1} from override directory..."
        rm -rf "${path}"
        cp -r "override/${1}" "${path}"
    else
        echo "Unpacking ${1}..."
        rm -rf "${path}"
        tar xf "$(tarpath $1)" -C "${build}"
    fi
}

is_built() {
    # Return true if the specified package is already built
    # $1  = package shortname
    local file
    for file in $(expand ${1}_artifacts)
    do
        if [ ! -e "${root}/bin/${file}" ] ; then
            return 1
        fi
    done
    return 0
}

do_configure() {
    # Run configure with the appropriate parameters.
    # Additional parameters can be specified as arguments.
    #
    # Fedora's ${build_host}-pkg-config clobbers search paths; avoid it
    #
    # Use only our pkg-config library directory, even on cross builds
    # https://bugzilla.redhat.com/show_bug.cgi?id=688171
    #
    # -static-libgcc is in ${ldflags} but libtool filters it out, so we
    # also pass it in CC
    ./configure \
            --host=${build_host} \
            --build=${build_system} \
            --prefix="$root" \
            --disable-static \
            --disable-dependency-tracking \
            PKG_CONFIG=pkg-config \
            PKG_CONFIG_LIBDIR="${root}/lib/pkgconfig" \
            PKG_CONFIG_PATH= \
            CC="${build_host}-gcc -static-libgcc" \
            CPPFLAGS="${cppflags} -I${root}/include" \
            CFLAGS="${cflags}" \
            CXXFLAGS="${cxxflags}" \
            LDFLAGS="${ldflags} -L${root}/lib" \
            "$@"
}

do_cmake() {
    # Run cmake with the appropriate parameters.
    # Additional parameters can be specified as arguments.
    #
    # Certain cmake variables cannot be specified on the command-line.
    # http://public.kitware.com/Bug/view.php?id=9980
    cat > toolchain.cmake <<EOF
SET(CMAKE_SYSTEM_NAME Windows)
SET(CMAKE_C_COMPILER ${build_host}-gcc)
SET(CMAKE_RC_COMPILER ${build_host}-windres)
EOF
    cmake -G "Unix Makefiles" \
            -DCMAKE_TOOLCHAIN_FILE="toolchain.cmake" \
            -DCMAKE_INSTALL_PREFIX="${root}" \
            -DCMAKE_FIND_ROOT_PATH="${root}" \
            -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
            -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
            -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
            -DCMAKE_C_FLAGS="${cppflags} ${cflags}" \
            -DCMAKE_CXX_FLAGS="${cppflags} ${cxxflags}" \
            -DCMAKE_EXE_LINKER_FLAGS="${ldflags}" \
            -DCMAKE_SHARED_LINKER_FLAGS="${ldflags}" \
            -DCMAKE_MODULE_LINKER_FLAGS="${ldflags}" \
            "$@" \
            .
}

build_one() {
    # Build the specified package and its dependencies if not already built
    # $1  = package shortname
    local builddir

    if is_built "$1" ; then
        return
    fi

    build $(expand ${1}_dependencies)

    unpack "$1"

    echo "Building ${1}..."
    builddir="${build}/$(expand ${1}_build)"
    pushd "$builddir" >/dev/null
    case "$1" in
    zlib)
        # Don't strip binaries during build
        make -f win32/Makefile.gcc $parallel \
                PREFIX="${build_host}-" \
                CFLAGS="${cppflags} ${cflags}" \
                LDFLAGS="${ldflags}" \
                STRIP="true" \
                all
        if [ "$can_test" = yes ] ; then
            make -f win32/Makefile.gcc \
                testdll
        fi
        make -f win32/Makefile.gcc \
                SHARED_MODE=1 \
                PREFIX="${build_host}-" \
                BINARY_PATH="${root}/bin" \
                INCLUDE_PATH="${root}/include" \
                LIBRARY_PATH="${root}/lib" install
        ;;
    png)
        do_configure
        make $parallel
        if [ "$can_test" = yes ] ; then
            make check
        fi
        make install
        ;;
    jpeg)
        do_configure \
                --without-turbojpeg
        make $parallel
        if [ "$can_test" = yes ] ; then
            make check
        fi
        make install
        ;;
    tiff)
        # TIF_PLATFORM_CONSOLE prevents the default warning/error handlers
        # from showing a dialog box.
        # http://lists.andrew.cmu.edu/pipermail/openslide-users/2013-July/000630.html
        do_configure \
                --with-zlib-include-dir="${root}/include" \
                --with-zlib-lib-dir="${root}/lib" \
                --with-jpeg-include-dir="${root}/include" \
                --with-jpeg-lib-dir="${root}/lib" \
                --disable-jbig \
                --disable-lzma \
                CPPFLAGS="${cppflags} -DTIF_PLATFORM_CONSOLE"
        make $parallel
        if [ "$can_test" = yes ] ; then
            # make check
            :
        fi
        make install
        ;;
    openjpeg)
        local saved_cflags
        # 32-bit binaries segfault in aperio-33005 test if OpenJPEG is built
        # with -msse2 (observed with OpenJPEG 2.1.0, gcc 4.9.2)
        saved_cflags="${cflags}"
        cflags="${cflags/-msse2/}"
        cflags="${cflags/-mfpmath=sse/}"
        do_cmake \
                -DCMAKE_DISABLE_FIND_PACKAGE_LCMS=TRUE \
                -DCMAKE_DISABLE_FIND_PACKAGE_LCMS2=TRUE \
                -DBUILD_PKGCONFIG_FILES=ON \
                -DBUILD_DOC=OFF
        make $parallel
        make install
        cflags="${saved_cflags}"
        ;;
    iconv)
        # Don't strip DLL during build
        sed -i 's/-Wl,-s //' Makefile
        make \
                CC="${build_host}-gcc" \
                AR="${build_host}-ar" \
                RANLIB="${build_host}-ranlib" \
                DLLTOOL="${build_host}-dlltool" \
                CFLAGS="${cppflags} ${cflags}" \
                SPECS_FLAGS="${ldflags} -static-libgcc"
        if [ "$can_test" = yes ] ; then
            make test \
                    CC="${build_host}-gcc" \
                    CFLAGS="${cppflags} ${cflags} ${ldflags}"
        fi
        make install \
                prefix="${root}"
        ;;
    gettext)
        # Missing tests for C++ compiler, which is only needed on Windows
        do_configure \
                CXX=${build_host}-g++ \
                --disable-java \
                --disable-native-java \
                --disable-csharp \
                --disable-libasprintf \
                --enable-threads=win32
        make $parallel
        if [ "$can_test" = yes ] ; then
            make check
        fi
        make install
        ;;
    ffi)
        do_configure
        make $parallel
        if [ "$can_test" = yes ] ; then
            # make check
            :
        fi
        make install
        ;;
    glib)
        # https://bugzilla.gnome.org/show_bug.cgi?id=754431
        sed -i 's/#include "config.h"/&\n#define MINGW_HAS_SECURE_API 1/' \
                glib/gstrfuncs.c
        do_configure \
                --with-threads=win32
        # Fix 32-bit Cygwin builds in a uniform way
        # https://bugzilla.gnome.org/show_bug.cgi?id=739656
        sed -i 's/#include "config.h"/\0\n#undef _WIN32_WINNT\n#define _WIN32_WINNT 0x0600/' \
                gio/gsocket.c
        sed -i -e "s/.*HAVE_IF_INDEXTONAME.*/#define HAVE_IF_INDEXTONAME 1/" \
                -e "s/.*HAVE_IF_NAMETOINDEX.*/#define HAVE_IF_NAMETOINDEX 1/" \
                config.h
        make $parallel
        make install
        ;;
    gdkpixbuf)
        do_configure \
                --disable-modules \
                --with-included-loaders \
                --without-gdiplus
        make $parallel
        if [ "$can_test" = yes ] ; then
            # make check
            :
        fi
        make install
        ;;
    pixman)
        # Use explicit Win32 TLS calls instead of declaring variables with
        # __thread.  This avoids a dependency on the winpthreads DLL if
        # GCC was built with POSIX threads support.
        do_configure \
                ac_cv_tls=none
        # Work around build failure with ac_cv_tls=none and recent
        # MinGW-w64 headers
        # https://sourceforge.net/p/mingw-w64/bugs/450/
        echo "#undef IN" >> pixman/pixman-compiler.h
        make $parallel
        if [ "$can_test" = yes ] ; then
            # make check
            :
        fi
        make install
        ;;
    cairo)
        do_configure \
                --enable-ft=no \
                --enable-xlib=no
        make $parallel
        if [ "$can_test" = yes ] ; then
            # make check
            :
        fi
        make install
        ;;
    xml)
        do_configure \
                --with-zlib="${root}" \
                --without-lzma \
                --without-python
        make $parallel
        if [ "$can_test" = yes ] ; then
            # make check
            :
        fi
        make install
        ;;
    sqlite)
        do_configure
        make $parallel
        make install
        # Extract public-domain dedication from the top of sqlite3.h
        awk '/\*{8}/ {exit} /^\*{2}/ {print}' sqlite3.h > PUBLIC-DOMAIN.txt
        ;;
    openslide)
        local ver_suffix_arg
        if [ -n "${ver_suffix}" ] ; then
            ver_suffix_arg="--with-version-suffix=${ver_suffix}"
        fi
        do_configure \
                "${ver_suffix_arg}"
        make $parallel
        if [ "$can_test" = yes ] ; then
            make check
        fi
        make install
        ;;
    openslidejava)
        do_configure \
                ANT_HOME="${ant_home}" \
                JAVA_HOME="${java_home}"
        make $parallel
        make install
        pushd "${root}/lib/openslide-java" >/dev/null
        cp ${openslidejava_artifacts} "${root}/bin/"
        popd >/dev/null
        ;;
    esac
    popd >/dev/null
}

build() {
    # Build the specified list of packages and their dependencies if not
    # already built
    # $*  = package shortnames
    local package
    for package in $*
    do
        build_one "$package"
    done
}

sdist() {
    # Build source distribution
    local package path xzpath zipdir
    zipdir="openslide-winbuild-${pkgver}"
    rm -rf "${zipdir}"
    mkdir -p "${zipdir}/tar"
    for package in $packages
    do
        fetch "$package"
        path="$(tarpath ${package})"
        xzpath="${path/%.gz/.xz}"
        if [ "$path" != "$xzpath" ] ; then
            # Tarball is compressed with gzip.
            # Recompress with xz to save space.
            echo "Recompressing ${package}..."
            gunzip -c "$path" | xz -9c > "${zipdir}/tar/$(basename ${xzpath})"
        else
            cp "$path" "${zipdir}/tar/"
        fi
    done
    cp build.sh README.md lgpl-2.1.txt "${zipdir}/"
    rm -f "${zipdir}.zip"
    zip -r "${zipdir}.zip" "${zipdir}"
    rm -r "${zipdir}"
}

bdist() {
    # Build binary distribution
    local package name licensedir zipdir prev_ver_suffix

    # Rebuild OpenSlide if suffix changed
    prev_ver_suffix="$(cat ${build_bits}/.suffix 2>/dev/null ||:)"
    if [ "${ver_suffix}" != "${prev_ver_suffix}" ] ; then
        clean openslide
        mkdir -p "${build_bits}"
        echo "${ver_suffix}" > "${build_bits}/.suffix"
    fi

    for package in $packages
    do
        build_one "$package"
    done
    zipdir="openslide-win${build_bits}-${pkgver}"
    rm -rf "${zipdir}"
    mkdir -p "${zipdir}/bin"
    for package in $packages
    do
        for artifact in $(expand ${package}_artifacts)
        do
            if [ "${artifact}" != "${artifact%.dll}" -o \
                    "${artifact}" != "${artifact%.exe}" ] ; then
                echo "Stripping ${artifact}..."
                ${build_host}-objcopy --only-keep-debug \
                        "${root}/bin/${artifact}" \
                        "${zipdir}/bin/${artifact}.debug"
                chmod -x "${zipdir}/bin/${artifact}.debug"
                ${build_host}-objcopy -S \
                        --add-gnu-debuglink="${zipdir}/bin/${artifact}.debug" \
                        "${root}/bin/${artifact}" \
                        "${zipdir}/bin/${artifact}"
            else
                cp "${root}/bin/${artifact}" "${zipdir}/bin/"
            fi
        done
        licensedir="${zipdir}/licenses/$(expand ${package}_name)"
        mkdir -p "${licensedir}"
        for artifact in $(expand ${package}_licenses)
        do
            cp "${build}/$(expand ${package}_build)/${artifact}" \
                    "${licensedir}"
        done
        name="$(expand ${package}_name)"
        if [ -n "$name" ] ; then
            printf "%-30s %s\n" "$name" "$(expand ${package}_ver)" >> \
                    "${zipdir}/VERSIONS.txt"
        fi
    done
    mkdir -p "${zipdir}/lib"
    cp "${root}/lib/libopenslide.dll.a" "${zipdir}/lib/libopenslide.lib"
    mkdir -p "${zipdir}/include"
    cp -r "${root}/include/openslide" "${zipdir}/include/"
    cp "${build}/${openslide_build}/README.txt" "${zipdir}/"
    rm -f "${zipdir}.zip"
    zip -r "${zipdir}.zip" "${zipdir}"
    rm -r "${zipdir}"
}

clean() {
    # Clean built files
    local package artifact
    if [ $# -gt 0 ] ; then
        for package in "$@"
        do
            echo "Cleaning ${package}..."
            for artifact in $(expand ${package}_artifacts)
            do
                rm -f "${root}/bin/${artifact}"
            done
        done
    else
        echo "Cleaning..."
        rm -rf 32 64 openslide-win*-*.zip
    fi
}

updates() {
    # Report new releases of software packages
    local package url curver newver
    for package in ant $packages
    do
        url="$(expand ${package}_upurl)"
        if [ -z "$url" ] ; then
            continue
        fi
        curver="$(expand ${package}_ver)"
        newver=$(${wget} -O- "$url" | \
                sed -nr "s%.*$(expand ${package}_upregex).*%\\1%p" | \
                sort -uV | \
                tail -n 1)
        if [ "${curver}" != "${newver}" ] ; then
            printf "%-15s %10s  => %10s\n" "${package}" "${curver}" "${newver}"
        fi
    done
}

probe() {
    # Probe the build environment and set up variables
    local arch_cflags

    build="${build_bits}/build"
    root="$(pwd)/${build_bits}/root"
    mkdir -p "${root}"

    fetch configguess
    build_system=$(sh "$configguess_path")

    if [ "$build_bits" = "64" ] ; then
        build_host=x86_64-w64-mingw32
    else
        build_host=i686-w64-mingw32
        arch_cflags="-msse2 -mfpmath=sse"
    fi
    if ! type ${build_host}-gcc >/dev/null 2>&1 ; then
        echo "Couldn't find suitable compiler."
        exit 1
    fi

    cppflags="-D_FORTIFY_SOURCE=2"
    cflags="-O2 -g -mms-bitfields -fexceptions ${arch_cflags}"
    cxxflags="${cflags}"
    ldflags="-static-libgcc -Wl,--enable-auto-image-base -Wl,--dynamicbase -Wl,--nxcompat"

    if ${build_host}-ld --help | grep -q -- --insert-timestamp ; then
        # Disable deterministic build feature in GNU ld 2.24 (disabled
        # by default in 2.25) which breaks detection of updated libraries
        # by bound executables
        # https://sourceware.org/bugzilla/show_bug.cgi?id=16887
        ldflags="${ldflags} -Wl,--insert-timestamp"
    fi

    case "$build_system" in
    *-*-cygwin)
        # Windows
        # We can only test a 64-bit build if we're also on a 64-bit kernel.
        # We can't probe for this using Cygwin tools because Cygwin is
        # exclusively 32-bit.  Check environment variables set by WOW64.
        if [ "$build_bits" = 64 -a "$PROCESSOR_ARCHITECTURE" != AMD64 -a \
                "$PROCESSOR_ARCHITEW6432" != AMD64 ] ; then
            can_test="no"
        else
            can_test="yes"
        fi

        ant_home="/opt/ant"
        java_home="${JAVA_HOME}"
        if [ -z "$java_home" ] ; then
            java_home=$(find "$(cygpath c:\\Program\ Files\\Java)" \
                    -maxdepth 1 -name "jdk*" -print -quit)
        fi
        if [ ! -e "$ant_home" ] ; then
            echo "Ant directory not found."
            exit 1
        fi
        if [ ! -e "$java_home" ] ; then
            echo "Java directory not found."
            exit 1
        fi
        ;;
    *)
        # Other
        can_test="no"
        ant_home=""
        java_home=""

        # Ensure Wine is not run via binfmt_misc, since some packages
        # attempt to run programs after building them.
        for hdr in PE MZ
        do
            echo $hdr > conftest
            chmod +x conftest
            if ./conftest 2>/dev/null ; then
                # Awkward construct due to "set -e"
                :
            elif [ $? = 193 ] ; then
                rm conftest
                echo "Wine is enabled in binfmt_misc.  Please disable it."
                exit 1
            fi
            rm conftest
        done
    esac
}

fail_handler() {
    # Report failed command
    echo "Failed: $BASH_COMMAND (line $BASH_LINENO)"
    exit 1
}


# Set up error handling
trap fail_handler ERR

# Cygwin setup bypasses normal startup
if [ "$1" = "setup" ] ; then
    setup_cygwin "$2"
    exit 0
fi

# Parse command-line options
parallel=""
build_bits=32
pkgver="$(date +%Y%m%d)-local"
ver_suffix=""
while getopts "j:m:p:s:" opt
do
    case "$opt" in
    j)
        parallel="-j${OPTARG}"
        ;;
    m)
        case ${OPTARG} in
        32|64)
            build_bits=${OPTARG}
            ;;
        *)
            echo "-m32 or -m64 only."
            exit 1
            ;;
        esac
        ;;
    p)
        pkgver="${OPTARG}"
        ;;
    s)
        ver_suffix="${OPTARG}"
        ;;
    esac
done
shift $(( $OPTIND - 1 ))

# Probe build environment
probe

# Process command-line arguments
case "$1" in
sdist)
    sdist
    ;;
bdist)
    bdist
    ;;
clean)
    shift
    clean "$@"
    ;;
updates)
    updates
    ;;
*)
    cat <<EOF
Usage: $0 setup /path/to/cygwin/setup.exe
       $0 [-p<pkgver>] sdist
       $0 [-j<n>] [-m{32|64}] [-p<pkgver>] [-s<suffix>] bdist
       $0 [-m{32|64}] clean [package...]
       $0 updates

Packages:
$packages
EOF
    exit 1
    ;;
esac
exit 0
