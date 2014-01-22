#!/bin/bash
#
# A script for building OpenSlide and its dependencies for Windows
#
# Copyright (c) 2011-2014 Carnegie Mellon University
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
cygtools="wget zip pkg-config make mingw64-i686-gcc-g++ mingw64-x86_64-gcc-g++ binutils nasm gettext-devel libglib2.0-devel"
ant_ver="1.9.3"
ant_url="http://archive.apache.org/dist/ant/binaries/apache-ant-${ant_ver}-bin.tar.bz2"
ant_build="apache-ant-${ant_ver}"  # not actually a source tree

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
configguess_ver="28d244f1"
zlib_ver="1.2.8"
png_ver="1.6.8"
jpeg_ver="1.3.0"
tiff_ver="4.0.3"
openjpeg_ver="1.5.1"
iconv_ver="0.0.6"
gettext_ver="0.18.3.1"
ffi_ver="3.0.13"
glib_basever="2.38"
glib_ver="${glib_basever}.2"
gdkpixbuf_basever="2.30"
gdkpixbuf_ver="${gdkpixbuf_basever}.3"
pixman_ver="0.32.4"
cairo_ver="1.12.16"
xml_ver="2.9.1"
sqlite_year="2013"
sqlite_ver="3.8.2"
sqlite_vernum="3080200"
openslide_ver="3.3.3"
openslidejava_ver="0.11.0"

# Tarball URLs
configguess_url="http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=${configguess_ver}"
zlib_url="http://prdownloads.sourceforge.net/libpng/zlib-${zlib_ver}.tar.xz"
png_url="http://prdownloads.sourceforge.net/libpng/libpng-${png_ver}.tar.xz"
jpeg_url="http://prdownloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-${jpeg_ver}.tar.gz"
tiff_url="ftp://ftp.remotesensing.org/pub/libtiff/tiff-${tiff_ver}.tar.gz"
openjpeg_url="http://openjpeg.googlecode.com/files/openjpeg-${openjpeg_ver}.tar.gz"
iconv_url="https://win-iconv.googlecode.com/files/win-iconv-${iconv_ver}.tar.bz2"
gettext_url="http://ftp.gnu.org/pub/gnu/gettext/gettext-${gettext_ver}.tar.gz"
ffi_url="ftp://sourceware.org/pub/libffi/libffi-${ffi_ver}.tar.gz"
glib_url="http://ftp.gnome.org/pub/gnome/sources/glib/${glib_basever}/glib-${glib_ver}.tar.xz"
gdkpixbuf_url="http://ftp.gnome.org/pub/gnome/sources/gdk-pixbuf/${gdkpixbuf_basever}/gdk-pixbuf-${gdkpixbuf_ver}.tar.xz"
pixman_url="http://cairographics.org/releases/pixman-${pixman_ver}.tar.gz"
cairo_url="http://cairographics.org/releases/cairo-${cairo_ver}.tar.xz"
xml_url="ftp://xmlsoft.org/libxml2/libxml2-${xml_ver}.tar.gz"
sqlite_url="http://www.sqlite.org/${sqlite_year}/sqlite-autoconf-${sqlite_vernum}.tar.gz"
openslide_url="http://download.openslide.org/releases/openslide/openslide-${openslide_ver}.tar.xz"
openslidejava_url="http://download.openslide.org/releases/openslide-java/openslide-java-${openslidejava_ver}.tar.xz"

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
openjpeg_artifacts="libopenjpeg-1.dll"
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
        echo "tar/config.guess"
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
            wget -q -O tar/config.guess "$url"
        else
            wget -P tar -q --no-check-certificate "$url"
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

build_one() {
    # Build the specified package and its dependencies if not already built
    # $1  = package shortname
    local builddir artifact

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
        make -f win32/Makefile.gcc $parallel \
                PREFIX="${build_host}-" \
                CFLAGS="${cppflags} ${cflags}" \
                LDFLAGS="${ldflags}" \
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
        do_configure
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
                CPPFLAGS="${cppflags} -DTIF_PLATFORM_CONSOLE"
        make $parallel
        if [ "$can_test" = yes ] ; then
            # make check
            :
        fi
        make install
        ;;
    openjpeg)
        do_configure \
                --disable-doc \
                TIFF_CFLAGS="-I${root}/include" \
                TIFF_LIBS="-L${root}/lib -ltiff"
        make $parallel
        make install
        ;;
    iconv)
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
        #
        # configure wrongly selects /usr/bin/nm during native builds
        # https://savannah.gnu.org/bugs/index.php?41203
        do_configure \
                CXX=${build_host}-g++ \
                NM=${build_host}-nm \
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
            make check
        fi
        make install
        ;;
    glib)
        do_configure \
                --disable-modular-tests \
                --with-threads=win32
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
        do_configure
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
        local suffix_arg
        if [ -n "${suffix}" ] ; then
            suffix_arg="--with-version-suffix=${suffix}"
        fi
        do_configure \
                "${suffix_arg}"
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
        # 0.11.0 marks the DLL non-executable, which causes load failures
        chmod +x openslide-jni.dll
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
    zipdir="openslide-winbuild-$(date +%Y%m%d)"
    if [ -n "${suffix}" ] ; then
        zipdir="${zipdir}-${suffix}"
    fi
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
    local package name licensedir zipdir prev_suffix

    # Rebuild OpenSlide if suffix changed
    prev_suffix="$(cat ${build_bits}/.suffix 2>/dev/null ||:)"
    if [ "${suffix}" != "${prev_suffix}" ] ; then
        clean openslide
        mkdir -p "${build_bits}"
        echo "${suffix}" > "${build_bits}/.suffix"
    fi

    for package in $packages
    do
        build_one "$package"
    done
    zipdir="openslide-win${build_bits}-$(date +%Y%m%d)"
    if [ -n "${suffix}" ] ; then
        zipdir="${zipdir}-${suffix}"
    fi
    rm -rf "${zipdir}"
    mkdir -p "${zipdir}/bin"
    for package in $packages
    do
        for artifact in $(expand ${package}_artifacts)
        do
            cp "${root}/bin/${artifact}" "${zipdir}/bin/"
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

probe() {
    # Probe the build environment and set up variables
    build="${build_bits}/build"
    root="$(pwd)/${build_bits}/root"
    mkdir -p "${root}"

    fetch configguess
    build_system=$(sh tar/config.guess)

    if [ "$build_bits" = "64" ] ; then
        build_host=x86_64-w64-mingw32
    else
        build_host=i686-w64-mingw32
    fi
    if ! type ${build_host}-gcc >/dev/null 2>&1 ; then
        echo "Couldn't find suitable compiler."
        exit 1
    fi

    cppflags="-D_FORTIFY_SOURCE=2"
    cflags="-O2 -g -mms-bitfields -fexceptions"
    cxxflags="${cflags}"
    ldflags="-static-libgcc -Wl,--enable-auto-image-base -Wl,--dynamicbase -Wl,--nxcompat"

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
            java_home=$(cygpath c:/Program\ Files/Java/jdk*)
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
suffix=""
while getopts "j:m:s:" opt
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
    s)
        suffix="${OPTARG}"
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
*)
    cat <<EOF
Usage: $0 setup /path/to/cygwin/setup.exe
       $0 [-s<suffix>] sdist
       $0 [-j<n>] [-m{32|64}] [-s<suffix>] bdist
       $0 [-m{32|64}] clean [package...]

Packages:
$packages
EOF
    exit 1
    ;;
esac
exit 0
