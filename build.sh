#!/bin/bash
#
# A script for building OpenSlide and its dependencies for Windows
#
# Copyright (c) 2011-2015 Carnegie Mellon University
# Copyright (c) 2022      Benjamin Gilbert
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

packages="ssp pthread zlib png jpeg tiff openjpeg iconv gettext ffi pcre glib gdkpixbuf pixman cairo xml sqlite openslide openslidejava"

# Package display names.  Missing packages are not included in VERSIONS.txt.
ssp_name="libssp"
pthread_name="winpthreads"
zlib_name="zlib"
png_name="libpng"
jpeg_name="libjpeg-turbo"
tiff_name="libtiff"
openjpeg_name="OpenJPEG"
iconv_name="win-iconv"
gettext_name="gettext"
ffi_name="libffi"
pcre_name="PCRE2"
glib_name="glib"
gdkpixbuf_name="gdk-pixbuf"
pixman_name="pixman"
cairo_name="cairo"
xml_name="libxml2"
sqlite_name="SQLite"
openslide_name="OpenSlide"
openslidejava_name="OpenSlide Java"

# Package versions
ssp_ver="12.2.0"
pthread_ver="10.0.0"
zlib_ver="1.2.13"
png_ver="1.6.39"
jpeg_ver="2.1.4"
tiff_ver="4.5.0"
openjpeg_ver="2.5.0"
iconv_ver="0.0.8"
gettext_ver="0.21.1"
ffi_ver="3.4.4"
pcre_ver="10.42"
glib_ver="2.74.3"
gdkpixbuf_ver="2.42.10"
pixman_ver="0.42.2"
cairo_ver="1.16.0"
xml_ver="2.10.3"
sqlite_year="2022"
sqlite_ver="3.40.0"
openslide_ver="3.4.1"
openslidejava_ver="0.12.2"

# Derived package version strings
glib_basever="$(echo ${glib_ver} | awk 'BEGIN {FS="."} {printf("%d.%d", $1, $2)}')"
gdkpixbuf_basever="$(echo ${gdkpixbuf_ver} | awk 'BEGIN {FS="."} {printf("%d.%d", $1, $2)}')"
xml_basever="$(echo ${xml_ver} | awk 'BEGIN {FS="."} {printf("%d.%d", $1, $2)}')"
sqlite_vernum="$(echo ${sqlite_ver} | awk 'BEGIN {FS="."} {printf("%d%02d%02d%02d\n", $1, $2, $3, $4)}')"

# Tarball URLs
ssp_url="https://mirrors.concertpass.com/gcc/releases/gcc-${ssp_ver}/gcc-${ssp_ver}.tar.xz"
pthread_url="https://prdownloads.sourceforge.net/mingw-w64/mingw-w64-v${pthread_ver}.tar.bz2"
zlib_url="https://zlib.net/zlib-${zlib_ver}.tar.xz"
png_url="https://prdownloads.sourceforge.net/libpng/libpng-${png_ver}.tar.xz"
jpeg_url="https://prdownloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-${jpeg_ver}.tar.gz"
tiff_url="https://download.osgeo.org/libtiff/tiff-${tiff_ver}.tar.xz"
openjpeg_url="https://github.com/uclouvain/openjpeg/archive/v${openjpeg_ver}.tar.gz"
iconv_url="https://github.com/win-iconv/win-iconv/archive/v${iconv_ver}.tar.gz"
gettext_url="https://ftp.gnu.org/pub/gnu/gettext/gettext-${gettext_ver}.tar.xz"
ffi_url="https://github.com/libffi/libffi/releases/download/v${ffi_ver}/libffi-${ffi_ver}.tar.gz"
pcre_url="https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${pcre_ver}/pcre2-${pcre_ver}.tar.bz2"
glib_url="https://download.gnome.org/sources/glib/${glib_basever}/glib-${glib_ver}.tar.xz"
gdkpixbuf_url="https://download.gnome.org/sources/gdk-pixbuf/${gdkpixbuf_basever}/gdk-pixbuf-${gdkpixbuf_ver}.tar.xz"
pixman_url="https://cairographics.org/releases/pixman-${pixman_ver}.tar.gz"
cairo_url="https://cairographics.org/releases/cairo-${cairo_ver}.tar.xz"
xml_url="https://download.gnome.org/sources/libxml2/${xml_basever}/libxml2-${xml_ver}.tar.xz"
sqlite_url="https://www.sqlite.org/${sqlite_year}/sqlite-autoconf-${sqlite_vernum}.tar.gz"
openslide_url="https://github.com/openslide/openslide/releases/download/v${openslide_ver}/openslide-${openslide_ver}.tar.xz"
openslidejava_url="https://github.com/openslide/openslide-java/releases/download/v${openslidejava_ver}/openslide-java-${openslidejava_ver}.tar.xz"

# Unpacked source trees
ssp_build="gcc-${ssp_ver}/libssp"
pthread_build="mingw-w64-v${pthread_ver}/mingw-w64-libraries/winpthreads"
zlib_build="zlib-${zlib_ver}"
png_build="libpng-${png_ver}"
jpeg_build="libjpeg-turbo-${jpeg_ver}"
tiff_build="tiff-${tiff_ver}"
openjpeg_build="openjpeg-${openjpeg_ver}"
iconv_build="win-iconv-${iconv_ver}"
gettext_build="gettext-${gettext_ver}/gettext-runtime"
ffi_build="libffi-${ffi_ver}"
pcre_build="pcre2-${pcre_ver}"
glib_build="glib-${glib_ver}"
gdkpixbuf_build="gdk-pixbuf-${gdkpixbuf_ver}"
pixman_build="pixman-${pixman_ver}"
cairo_build="cairo-${cairo_ver}"
xml_build="libxml2-${xml_ver}"
sqlite_build="sqlite-autoconf-${sqlite_vernum}"
openslide_build="openslide-${openslide_ver}"
openslidejava_build="openslide-java-${openslidejava_ver}"

# Locations of license files within the source tree
ssp_licenses="../COPYING3 ../COPYING.RUNTIME"
pthread_licenses="COPYING"
zlib_licenses="README"
png_licenses="LICENSE"
jpeg_licenses="LICENSE.md README.ijg simd/nasm/jsimdext.inc" # !!!
tiff_licenses="LICENSE.md"
openjpeg_licenses="LICENSE"
iconv_licenses="readme.txt"
gettext_licenses="COPYING intl/COPYING.LIB"
ffi_licenses="LICENSE"
pcre_licenses="LICENCE"
glib_licenses="COPYING"
gdkpixbuf_licenses="COPYING"
pixman_licenses="COPYING"
cairo_licenses="COPYING COPYING-LGPL-2.1 COPYING-MPL-1.1"
xml_licenses="Copyright"
sqlite_licenses="PUBLIC-DOMAIN.txt"
# Remove workaround in bdist() when updating these
openslide_licenses="LICENSE.txt lgpl-2.1.txt COPYING.LESSER"
openslidejava_licenses="LICENSE.txt lgpl-2.1.txt COPYING.LESSER"

# Build dependencies
ssp_dependencies=""
pthread_dependencies=""
zlib_dependencies=""
png_dependencies="zlib"
jpeg_dependencies=""
tiff_dependencies="zlib jpeg"
openjpeg_dependencies="png tiff"
iconv_dependencies=""
gettext_dependencies="iconv"
ffi_dependencies=""
pcre_dependencies=""
glib_dependencies="zlib iconv gettext ffi pcre"
gdkpixbuf_dependencies="glib"
pixman_dependencies="pthread"
cairo_dependencies="zlib png pixman"
xml_dependencies="zlib iconv"
sqlite_dependencies=""
openslide_dependencies="ssp pthread png jpeg tiff openjpeg glib gdkpixbuf cairo xml sqlite"
openslidejava_dependencies="openslide"

# Build artifacts
ssp_artifacts="libssp-0.dll"
pthread_artifacts="libwinpthread-1.dll"
zlib_artifacts="zlib1.dll"
png_artifacts="libpng16-16.dll"
jpeg_artifacts="libjpeg-62.dll"
tiff_artifacts="libtiff-6.dll"
openjpeg_artifacts="libopenjp2.dll"
iconv_artifacts="iconv.dll"
gettext_artifacts="libintl-8.dll"
ffi_artifacts="libffi-8.dll"
pcre_artifacts="libpcre2-8-0.dll"
glib_artifacts="libglib-2.0-0.dll libgthread-2.0-0.dll libgobject-2.0-0.dll libgio-2.0-0.dll libgmodule-2.0-0.dll"
gdkpixbuf_artifacts="libgdk_pixbuf-2.0-0.dll"
pixman_artifacts="libpixman-1-0.dll"
cairo_artifacts="libcairo-2.dll"
xml_artifacts="libxml2-2.dll"
sqlite_artifacts="libsqlite3-0.dll"
openslide_artifacts="libopenslide-0.dll openslide-quickhash1sum.exe openslide-show-properties.exe openslide-write-png.exe"
openslidejava_artifacts="openslide-jni.dll openslide.jar"

# Update-checking URLs
ssp_upurl="https://mirrors.concertpass.com/gcc/releases/"
zlib_upurl="https://zlib.net/"
png_upurl="http://www.libpng.org/pub/png/libpng.html"
jpeg_upurl="https://sourceforge.net/projects/libjpeg-turbo/files/"
tiff_upurl="https://download.osgeo.org/libtiff/"
openjpeg_upurl="https://github.com/uclouvain/openjpeg/tags"
iconv_upurl="https://github.com/win-iconv/win-iconv/tags"
gettext_upurl="https://ftp.gnu.org/pub/gnu/gettext/"
ffi_upurl="https://github.com/libffi/libffi/tags"
pcre_upurl="https://github.com/PCRE2Project/pcre2/tags"
glib_upurl="https://gitlab.gnome.org/GNOME/glib/tags"
gdkpixbuf_upurl="https://gitlab.gnome.org/GNOME/gdk-pixbuf/tags"
pixman_upurl="https://cairographics.org/releases/"
cairo_upurl="https://cairographics.org/releases/"
xml_upurl="https://gitlab.gnome.org/GNOME/libxml2/tags"
sqlite_upurl="https://sqlite.org/changes.html"
openslide_upurl="https://github.com/openslide/openslide/tags"
openslidejava_upurl="https://github.com/openslide/openslide-java/tags"

# Update-checking regexes
ssp_upregex="gcc-([0-9.]+)/"
zlib_upregex="source code, version ([0-9.]+)"
png_upregex="libpng-([0-9.]+)-README.txt"
jpeg_upregex="files/([0-9.]+)/"
tiff_upregex="tiff-([0-9.]+)\.tar"
openjpeg_upregex="archive/refs/tags/v([0-9.]+)\.tar"
iconv_upregex="archive/refs/tags/v([0-9.]+)\.tar"
gettext_upregex="gettext-([0-9.]+)\.tar"
ffi_upregex="archive/refs/tags/v([0-9.]+)\.tar"
pcre_upregex="archive/refs/tags/pcre2-([0-9.]+)\.tar"
glib_upregex="archive/([0-9]+\.[0-9]*[02468]\.[0-9]+)/"
gdkpixbuf_upregex="archive/([0-9]+\.[0-9]*[02468]\.[0-9]+)/"
pixman_upregex="pixman-([0-9.]+)\.tar"
cairo_upregex="\"cairo-([0-9.]+)\.tar"
xml_upregex="archive/v([0-9.]+)/"
sqlite_upregex="[0-9]{4}-[0-9]{2}-[0-9]{2} \(([0-9.]+)\)"
openslide_upregex="archive/refs/tags/v([0-9.]+)\.tar"
# Exclude old v1.0.0 tag
openslidejava_upregex="archive/refs/tags/v1\.0\.0\.tar.*|.*archive/refs/tags/v([0-9.]+)\.tar"

# wget standard options
wget="wget -q"


expand() {
    # Print the contents of the named variable
    # $1  = the name of the variable to expand
    echo "${!1}"
}

tarpath() {
    # Print the tarball path for the specified package
    # $1  = the name of the program
    local path xzpath
    path="tar/$(basename $(expand ${1}_url))"
    xzpath="${path/%.gz/.xz}"
    xzpath="${xzpath/%.bz2/.xz}"
    # Prefer tarball recompressed with xz, if available
    if [ -e "$xzpath" ] ; then
        echo "$xzpath"
    else
        echo "$path"
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
        ${wget} -P tar "$url"
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
        # Preserve timestamps to avoid spurious rebuilds of distributed files
        cp -pr "override/${1}" "${path}"
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
    # openSUSE sets $CONFIG_SITE to a script which changes libdir to
    # "${exec_prefix}/lib64" when building for 64-bit hosts
    # https://lists.andrew.cmu.edu/pipermail/openslide-users/2016-July/001263.html
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
            --build=x86_64-pc-linux-gnu \
            --prefix="$root" \
            --disable-static \
            --disable-dependency-tracking \
            CONFIG_SITE= \
            PKG_CONFIG=pkg-config \
            PKG_CONFIG_LIBDIR="${root}/lib/pkgconfig" \
            PKG_CONFIG_PATH= \
            CC="${build_host}-gcc -static-libgcc" \
            CPPFLAGS="${cppflags}" \
            CFLAGS="${cflags}" \
            CXXFLAGS="${cxxflags}" \
            LDFLAGS="${ldflags}" \
            "$@"
}

do_cmake() {
    # Run cmake with the appropriate parameters.
    # Additional parameters can be specified as arguments.
    #
    # Use only our pkg-config library directory, even on cross builds
    # https://bugzilla.redhat.com/show_bug.cgi?id=688171
    #
    # Certain cmake variables cannot be specified on the command-line.
    # http://public.kitware.com/Bug/view.php?id=9980
    cat > toolchain.cmake <<EOF
SET(CMAKE_SYSTEM_NAME Windows)
SET(CMAKE_SYSTEM_PROCESSOR ${cmake_system_processor})
SET(CMAKE_C_COMPILER ${build_host}-gcc)
SET(CMAKE_CXX_COMPILER ${build_host}-g++)
SET(CMAKE_RC_COMPILER ${build_host}-windres)
EOF
    PKG_CONFIG_LIBDIR="${root}/lib/pkgconfig" \
            PKG_CONFIG_PATH= \
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

do_meson_setup() {
    # Run meson setup with the appropriate parameters.
    # Additional parameters can be specified as arguments.
    #
    # Fedora's ${build_host}-pkg-config clobbers search paths; avoid it
    #
    # Use only our pkg-config library directory, even on cross builds
    # https://bugzilla.redhat.com/show_bug.cgi?id=688171
    cat > cross.ini <<EOF
[built-in options]
prefix = '${root}'
c_args = $(make_meson_list "${cppflags} ${cflags}")
c_link_args = $(make_meson_list "${ldflags}")
cpp_args = $(make_meson_list "${cppflags} ${cxxflags}")
cpp_link_args = $(make_meson_list "${ldflags}")
pkg_config_path = ''

[properties]
pkg_config_libdir = '${root}/lib/pkgconfig'

[binaries]
ar = '${build_host}-ar'
c = '${build_host}-gcc'
cpp = '${build_host}-g++'
ld = '${build_host}-ld'
objcopy = '${build_host}-objcopy'
pkgconfig = 'pkg-config'
strip = '${build_host}-strip'
windres = '${build_host}-windres'

[host_machine]
system = 'windows'
endian = 'little'
cpu_family = '${meson_cpu_family}'
cpu = '${meson_cpu}'
EOF
    meson setup \
            --buildtype plain \
            --cross-file cross.ini \
            --wrap-mode nofallback \
            "$@"
}

make_meson_list() {
    echo "$1" | sed -E -e "s/^ */['/" -e "s/ *$/']/" -e "s/ +/', '/g"
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
    ssp)
        # On Fedora the MinGW CRT is built with _FORTIFY_SOURCE so we need
        # to ship libssp.
        # https://bugzilla.redhat.com/show_bug.cgi?id=2002656
        do_configure \
                --disable-multilib \
                --with-target-subdir=.
        make $parallel
        # Copy the DLL but not the import library.  We want everything to
        # use the linkage that comes with the compiler, but want to supply
        # our own DLL so we can provide complete corresponding source.
        mkdir -p "${root}/bin"
        cp ".libs/${ssp_artifacts}" "${root}/bin"
        ;;
    pthread)
        do_configure
        make $parallel
        make install
        ;;
    zlib)
        # Don't strip binaries during build
        make -f win32/Makefile.gcc $parallel \
                PREFIX="${build_host}-" \
                CFLAGS="${cppflags} ${cflags}" \
                LDFLAGS="${ldflags}" \
                STRIP="true" \
                all
        make -f win32/Makefile.gcc \
                SHARED_MODE=1 \
                PREFIX="${build_host}-" \
                BINARY_PATH="${root}/bin" \
                INCLUDE_PATH="${root}/include" \
                LIBRARY_PATH="${root}/lib" install
        ;;
    png)
        do_configure \
                --enable-intel-sse
        make $parallel
        make install
        ;;
    jpeg)
        do_cmake \
                -DWITH_TURBOJPEG=0
        make $parallel
        make install
        ;;
    tiff)
        do_configure \
                --with-zlib-include-dir="${root}/include" \
                --with-zlib-lib-dir="${root}/lib" \
                --with-jpeg-include-dir="${root}/include" \
                --with-jpeg-lib-dir="${root}/lib" \
                --disable-jbig \
                --disable-lzma
        make $parallel
        make install
        ;;
    openjpeg)
        do_cmake \
                -DCMAKE_DISABLE_FIND_PACKAGE_LCMS=TRUE \
                -DCMAKE_DISABLE_FIND_PACKAGE_LCMS2=TRUE \
                -DBUILD_PKGCONFIG_FILES=ON \
                -DBUILD_DOC=OFF
        make $parallel
        make install
        ;;
    iconv)
        # Don't strip DLL during build
        sed -i 's/-Wl,-s //' Makefile
        make \
                CC="${build_host}-gcc" \
                AR="${build_host}-ar" \
                RANLIB="${build_host}-ranlib" \
                DLLTOOL="${build_host}-dlltool" \
                CFLAGS="${cppflags} ${cflags} ${ldflags}" \
                SPECS_FLAGS="${ldflags} -static-libgcc"
        make install \
                prefix="${root}"
        ;;
    gettext)
        do_configure \
                --disable-java \
                --disable-native-java \
                --disable-csharp \
                --disable-libasprintf \
                --enable-threads=win32
        make $parallel
        make install
        ;;
    ffi)
        do_configure \
                --disable-builddir
        make $parallel
        make install
        ;;
    pcre)
        do_configure
        make $parallel
        make install
        ;;
    glib)
        do_meson_setup build
        meson compile -C build $parallel
        meson install -C build
        ;;
    gdkpixbuf)
        do_meson_setup build \
                -Dpng=disabled \
                -Dtiff=disabled \
                -Djpeg=disabled \
                -Dman=false \
                -Dbuiltin_loaders="['bmp']" \
                -Dinstalled_tests=false
        meson compile -C build $parallel
        meson install -C build
        ;;
    pixman)
        do_meson_setup build \
                -Dopenmp=disabled
        # https://gitlab.freedesktop.org/pixman/pixman/-/merge_requests/60
        sed -i 's/defined(__SUNPRO_C) || defined(_MSC_VER)/defined(__SSE2__) || \0/' \
                pixman/pixman-mmx.c
        meson compile -C build $parallel
        meson install -C build
        ;;
    cairo)
        do_configure \
                --enable-ft=no \
                --enable-xlib=no
        # Test requires freetype but is compiled unconditionally
        # Fixed in cairo d331c69f65
        >test/font-variations.c
        make $parallel
        make install
        ;;
    xml)
        do_configure \
                --with-zlib="${root}" \
                --without-lzma \
                --without-python
        make $parallel
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
        make $parallel \
                CFLAGS="${cflags} ${openslide_werror}"
        make install
        ;;
    openslidejava)
        if [ -f meson.build ]; then
            do_meson_setup build ${openslide_werror:+--werror}
            meson compile -C build $parallel
            meson install -C build
        else
            do_configure
            # https://github.com/openslide/openslide-java/commit/bfa80947
            sed -i s/1.6/1.8/ build.xml
            make $parallel \
                    CFLAGS="${cflags} ${openslide_werror}"
            make install
        fi
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
        xzpath="${xzpath/%.bz2/.xz}"
        if [ "${path%.gz}" != "$path" ] ; then
            # Tarball is compressed with gzip.
            # Recompress with xz to save space.
            echo "Recompressing ${package} from gzip..."
            gunzip -c "$path" | xz -9c > "${zipdir}/tar/$(basename ${xzpath})"
        elif [ "${path%.bz2}" != "$path" ] ; then
            # Tarball is compressed with bzip2.
            # Recompress with xz to save space.
            echo "Recompressing ${package} from bzip2..."
            bunzip2 -c "$path" | xz -9c > "${zipdir}/tar/$(basename ${xzpath})"
        else
            cp "$path" "${zipdir}/tar/"
        fi
    done
    cp build.sh Dockerfile.builder README.md COPYING.LESSER "${zipdir}/"
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
            if ! cp "${build}/$(expand ${package}_build)/${artifact}" \
                    "${licensedir}" 2>/dev/null; then
                # OpenSlide and OpenSlide Java license files were renamed;
                # support both until the next releases
                case "${package}" in
                openslide|openslidejava) ;;
                *)
                    echo "Failed to copy ${artifact} from ${package}."
                    exit 1
                esac
            fi
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
    if [ -f "${build}/${openslide_build}/README.md" ]; then
        cp "${build}/${openslide_build}/README.md" "${zipdir}/"
    else
        cp "${build}/${openslide_build}/README.txt" "${zipdir}/"
    fi
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
    for package in $packages
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

    if [ "$build_bits" = "64" ] ; then
        build_host=x86_64-w64-mingw32
        cmake_system_processor=AMD64
        meson_cpu_family=x86_64
        meson_cpu=x86_64
    else
        build_host=i686-w64-mingw32
        cmake_system_processor=x86
        meson_cpu_family=x86
        meson_cpu=i686
        arch_cflags="-msse2 -mfpmath=sse -mstackrealign"
    fi
    if ! type ${build_host}-gcc >/dev/null 2>&1 ; then
        echo "Couldn't find suitable compiler."
        exit 1
    fi

    cppflags="-I${root}/include"
    cflags="-O2 -g -mms-bitfields -fexceptions -ftree-vectorize ${arch_cflags}"
    cxxflags="${cflags}"
    ldflags="-L${root}/lib -static-libgcc -Wl,--enable-auto-image-base -Wl,--dynamicbase -Wl,--nxcompat -lssp"

    # On 64-bit Windows, MinGW passes a frame pointer to _setjmp so longjmp
    # can do a SEH unwind.  This seems to work when the caller is also built
    # with MinGW, but sometimes crashes with STATUS_BAD_STACK when the
    # caller is built with MSVC; it appears that this is a longstanding
    # MinGW issue.  In 64-bit builds, override setjmp() to pass a NULL frame
    # pointer to skip the SEH unwind.  Our uses of setjmp/longjmp are all in
    # libpng/libjpeg error handling, which isn't expecting to do any cleanup
    # in intermediate stack frames, so this should be fine.
    # https://github.com/openslide/openslide-winbuild/issues/47
    mkdir -p "${root}/include"
    cat > "${root}/include/setjmp.h" <<EOF
#ifndef OPENSLIDE_SETJMP_H
#define OPENSLIDE_SETJMP_H

/* gcc extension */
#include_next <setjmp.h>

#ifdef __x86_64__
#undef setjmp
#define setjmp(buf) _setjmp(buf, NULL)
#endif

#endif
EOF

    # Ensure Wine is not run via binfmt_misc, since some packages
    # attempt to run programs after building them.
    for hdr in PE MZ
    do
        echo $hdr > conftest
        chmod +x conftest
        if ./conftest >/dev/null 2>&1 || [ $? = 193 ]; then
            rm conftest
            echo "Wine is enabled in binfmt_misc.  Please disable it."
            exit 1
        fi
        rm conftest
    done
}

fail_handler() {
    # Report failed command
    echo "Failed: $BASH_COMMAND (line $BASH_LINENO)"
    exit 1
}


# Set up error handling
trap fail_handler ERR

# Parse command-line options
parallel=""
build_bits=32
pkgver="$(date +%Y%m%d)-local"
ver_suffix=""
openslide_werror=""
while getopts "j:m:p:s:w" opt
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
    w)
        openslide_werror="-Werror"
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
Usage: $0 [-p<pkgver>] sdist
       $0 [-j<n>] [-m{32|64}] [-p<pkgver>] [-s<suffix>] [-w] bdist
       $0 [-m{32|64}] clean [package...]
       $0 updates

Packages:
$packages
EOF
    exit 1
    ;;
esac
exit 0
