#!/bin/bash

set -eE

packages="configguess zlib png jpeg tiff openjpeg iconv gettext ffi glib pkgconfig pixman cairo xml openslide openslidejava"

# Package display names.  Missing packages are not included in VERSIONS.txt.
zlib_name="zlib"
png_name="libpng"
jpeg_name="libjpeg-turbo"
tiff_name="libtiff"
openjpeg_name="OpenJPEG"
iconv_name="libiconv"
gettext_name="gettext"
ffi_name="libffi"
glib_name="glib"
pixman_name="pixman"
cairo_name="cairo"
xml_name="libxml2"
openslide_name="OpenSlide"
openslidejava_name="OpenSlide Java"

# Package versions
configguess_ver="fc7ed3ed"
zlib_ver="1.2.7"
png_ver="1.5.12"
jpeg_ver="1.2.1"
tiff_ver="4.0.2"
openjpeg_ver="1.5.0"
iconv_ver="1.14"
gettext_ver="0.18.1.1"
ffi_ver="3.0.11"
glib_basever="2.32"
glib_ver="${glib_basever}.3"
pkgconfig_ver="0.27"
pixman_ver="0.26.2"
cairo_ver="1.12.2"
xml_ver="2.8.0"
openslide_ver="3.2.6"
openslidejava_ver="0.10.0"

# Tarball URLs
configguess_url="http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=${configguess_ver}"
zlib_url="http://prdownloads.sourceforge.net/libpng/zlib-${zlib_ver}.tar.bz2"
png_url="http://prdownloads.sourceforge.net/libpng/libpng-${png_ver}.tar.xz"
jpeg_url="http://prdownloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-${jpeg_ver}.tar.gz"
tiff_url="ftp://ftp.remotesensing.org/pub/libtiff/tiff-${tiff_ver}.tar.gz"
openjpeg_url="http://openjpeg.googlecode.com/files/openjpeg-${openjpeg_ver}.tar.gz"
iconv_url="http://ftp.gnu.org/pub/gnu/libiconv/libiconv-${iconv_ver}.tar.gz"
gettext_url="http://ftp.gnu.org/pub/gnu/gettext/gettext-${gettext_ver}.tar.gz"
ffi_url="ftp://sourceware.org/pub/libffi/libffi-${ffi_ver}.tar.gz"
glib_url="http://ftp.gnome.org/pub/gnome/sources/glib/${glib_basever}/glib-${glib_ver}.tar.xz"
pkgconfig_url="http://pkgconfig.freedesktop.org/releases/pkg-config-${pkgconfig_ver}.tar.gz"
pixman_url="http://cairographics.org/releases/pixman-${pixman_ver}.tar.gz"
cairo_url="http://cairographics.org/releases/cairo-${cairo_ver}.tar.xz"
xml_url="ftp://xmlsoft.org/libxml2/libxml2-${xml_ver}.tar.gz"
openslide_url="http://github.com/downloads/openslide/openslide/openslide-${openslide_ver}.tar.xz"
openslidejava_url="http://github.com/downloads/openslide/openslide-java/openslide-java-${openslidejava_ver}.tar.xz"

# Unpacked source trees
zlib_build="zlib-${zlib_ver}"
png_build="libpng-${png_ver}"
jpeg_build="libjpeg-turbo-${jpeg_ver}"
tiff_build="tiff-${tiff_ver}"
openjpeg_build="openjpeg-${openjpeg_ver}"
iconv_build="libiconv-${iconv_ver}"
gettext_build="gettext-${gettext_ver}/gettext-runtime"
ffi_build="libffi-${ffi_ver}"
glib_build="glib-${glib_ver}"
pkgconfig_build="pkg-config-${pkgconfig_ver}"
pixman_build="pixman-${pixman_ver}"
cairo_build="cairo-${cairo_ver}"
xml_build="libxml2-${xml_ver}"
openslide_build="openslide-${openslide_ver}"
openslidejava_build="openslide-java-${openslidejava_ver}"

# Locations of license files within the source tree
zlib_licenses="README"
png_licenses="png.h"  # !!!
jpeg_licenses="README README-turbo.txt"
tiff_licenses="COPYRIGHT"
openjpeg_licenses="LICENSE"
iconv_licenses="COPYING.LIB"
gettext_licenses="COPYING intl/COPYING.LIB-2.0 intl/COPYING.LIB-2.1"
ffi_licenses="LICENSE"
glib_licenses="COPYING"
pixman_licenses="COPYING"
cairo_licenses="COPYING COPYING-LGPL-2.1 COPYING-MPL-1.1"
xml_licenses="COPYING"
openslide_licenses="LICENSE.txt lgpl-2.1.txt"
openslidejava_licenses="LICENSE.txt lgpl-2.1.txt"

# Build dependencies
zlib_dependencies=""
png_dependencies="zlib"
jpeg_dependencies=""
tiff_dependencies="zlib jpeg"
openjpeg_dependencies="png tiff pkgconfig"
iconv_dependencies=""
gettext_dependencies="iconv"
ffi_dependencies=""
glib_dependencies="zlib iconv gettext ffi"
pkgconfig_dependencies="glib"
pixman_dependencies="pkgconfig"
cairo_dependencies="pkgconfig zlib png pixman"
xml_dependencies="zlib iconv"
openslide_dependencies="pkgconfig png jpeg tiff openjpeg glib cairo xml"
openslidejava_dependencies="pkgconfig openslide"

# Build artifacts
zlib_artifacts="zlib1.dll"
png_artifacts="libpng15-15.dll"
jpeg_artifacts="libjpeg-62.dll"
tiff_artifacts="libtiff-5.dll"
openjpeg_artifacts="libopenjpeg-1.dll"
iconv_artifacts="libiconv-2.dll libcharset-1.dll"
gettext_artifacts="libintl-8.dll"
ffi_artifacts="libffi-6.dll"
glib_artifacts="libglib-2.0-0.dll libgthread-2.0-0.dll"
# pkg-config is used for build, but not distributed
pkgconfig_artifacts=""
pixman_artifacts="libpixman-1-0.dll"
cairo_artifacts="libcairo-2.dll"
xml_artifacts="libxml2-2.dll"
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
    if [ "$1" = "configguess" ] ; then
        # Can't be derived from URL
        echo "tar/config.guess"
    else
        echo "tar/$(basename $(expand ${1}_url))"
    fi
}

install_tool() {
    # Install specified program into MSYS if not present
    # $1  = the name of the program
    if (! type "$1" && type mingw-get) >/dev/null 2>&1 ; then
        echo "Installing ${1}..."
        mingw-get install "msys-$1-bin"
    fi
}

fetch() {
    # Fetch the specified package
    # $1  = package shortname
    local url
    url="$(expand ${1}_url)"
    install_tool wget
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
    fetch "${1}"
    echo "Unpacking ${1}..."
    mkdir -p "${build}"
    rm -rf "${build}/$(expand ${1}_build)"
    tar xf "$(tarpath $1)" -C "${build}"
}

is_built() {
    # Return true if the specified package is already built
    # $1  = package shortname
    local file
    if [ "$1" = "pkgconfig" ] ; then
        # Special case: no distributed artifacts; built only on Windows
        [ "$build_type" = "cross" -o -e "${root}/bin/pkg-config.exe" ]
        return
    else
        for file in $(expand ${1}_artifacts)
        do
            if [ ! -e "${root}/bin/${file}" ] ; then
                return 1
            fi
        done
        return 0
    fi
}

_configure_common() {
    # Helper function to run configure

    # Use only our pkg-config library directory, even on cross builds
    # https://bugzilla.redhat.com/show_bug.cgi?id=688171
    ./configure \
            --prefix="$root" \
            --disable-static \
            CPPFLAGS="-I${root}/include" \
            LDFLAGS="-L${root}/lib" \
            "$@"
}

do_configure() {
    # Run configure with the appropriate parameters.
    # Additional parameters can be specified as arguments.
    if [ "$build_type" = "native" ] ; then
        _configure_common \
                PKG_CONFIG="${root}/bin/pkg-config.exe" \
                "$@"
    else
        # Fedora's ${build_host}-pkg-config clobbers search paths; avoid it
        _configure_common \
                --host=${build_host} \
                --build=${build_system} \
                PKG_CONFIG=pkg-config \
                PKG_CONFIG_LIBDIR="${root}/lib/pkgconfig" \
                PKG_CONFIG_PATH= \
                "$@"
    fi
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
                PREFIX="${build_host_prefix}" \
                IMPLIB=libz.dll.a all
        if [ "$build_type" = "native" ] ; then
            make -f win32/Makefile.gcc \
                IMPLIB=libz.dll.a testdll
        fi
        make -f win32/Makefile.gcc \
                SHARED_MODE=1 \
                PREFIX="${build_host_prefix}" \
                IMPLIB=libz.dll.a \
                BINARY_PATH="${root}/bin" \
                INCLUDE_PATH="${root}/include" \
                LIBRARY_PATH="${root}/lib" install
        ;;
    png)
        do_configure
        make $parallel
        if [ "$build_type" = "native" ] ; then
            make check
        fi
        make install
        ;;
    jpeg)
        do_configure
        make $parallel
        if [ "$build_type" = "native" ] ; then
            make check
        fi
        make install
        ;;
    tiff)
        do_configure \
                --with-zlib-include-dir="${root}/include" \
                --with-zlib-lib-dir="${root}/lib" \
                --with-jpeg-include-dir="${root}/include" \
                --with-jpeg-lib-dir="${root}/lib"
        make $parallel
        if [ "$build_type" = "native" ] ; then
            make check
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
        do_configure
        make $parallel
        if [ "$build_type" = "native" ] ; then
            make check
        fi
        make install
        ;;
    gettext)
        # Missing tests for C++ compiler, which is only needed on Windows
        do_configure \
                CXX=${build_host_prefix}g++ \
                --disable-java \
                --disable-native-java \
                --disable-csharp \
                --disable-libasprintf \
                --enable-threads=win32
        make $parallel
        if [ "$build_type" = "native" ] ; then
            make check
        fi
        make install
        ;;
    ffi)
        do_configure
        make $parallel
        if [ "$build_type" = "native" ] ; then
            make check
        fi
        make install
        ;;
    glib)
        do_configure
        make $parallel
        if [ "$build_type" = "native" ] ; then
            # make check
            :
        fi
        make install
        ;;
    pkgconfig)
        # Only built during native builds
        do_configure \
                GLIB_CFLAGS="-I${root}/include/glib-2.0 -I${root}/lib/glib-2.0/include" \
                GLIB_LIBS="-L${root}/lib -lglib-2.0 -lintl"
        make $parallel
        if [ "$build_type" = "native" ] ; then
            # make check
            :
        fi
        make install
        ;;
    pixman)
        do_configure
        make $parallel
        if [ "$build_type" = "native" ] ; then
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
        if [ "$build_type" = "native" ] ; then
            # make check
            :
        fi
        make install
        ;;
    xml)
        do_configure \
                --without-python
        make $parallel
        if [ "$build_type" = "native" ] ; then
            make check
        fi
        make install
        ;;
    openslide)
        # Work around OpenSlide 3.2.6 compile failure on mingw-w64
        sed -i s/fseeko/_openslide_fseek/g src/*
        sed -i s/ftello/_openslide_ftell/g src/*
        do_configure
        make $parallel
        if [ "$build_type" = "native" ] ; then
            make check
        fi
        make install
        ;;
    openslidejava)
        do_configure \
                ANT_HOME=${ant_home} \
                JAVA_HOME=${java_home}
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
    local package zipdir
    zipdir="openslide-winbuild-$(date +%Y%m%d)"
    rm -rf "${zipdir}"
    mkdir -p "${zipdir}/tar"
    for package in $packages
    do
        fetch "$package"
        cp "$(tarpath ${package})" "${zipdir}/tar/"
    done
    cp build.sh README.txt TODO.txt "${zipdir}/"
    install_tool zip
    rm -f "${zipdir}.zip"
    zip -r "${zipdir}.zip" "${zipdir}"
    rm -r "${zipdir}"
}

bdist() {
    # Build binary distribution
    local package name licensedir zipdir
    for package in $packages
    do
        build_one "$package"
    done
    zipdir="openslide-win${build_bits}-$(date +%Y%m%d)"
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
    mkdir -p "${zipdir}/include"
    cp -r "${root}/include/openslide" "${zipdir}/include/"
    cp "${build}/${openslide_build}/README.txt" "${zipdir}/"
    install_tool zip
    rm -f "${zipdir}.zip"
    zip -r "${zipdir}.zip" "${zipdir}"
    rm -r "${zipdir}"
}

clean() {
    # Clean built files
    echo "Cleaning..."
    rm -rf 32 64 openslide-win*-*.zip VERSIONS.txt
}

probe() {
    # Probe the build environment and set up variables
    local host arch

    build="${build_bits}/build"
    root="$(pwd)/${build_bits}/root"
    mkdir -p "${root}"

    fetch configguess
    build_system=$(sh tar/config.guess)

    case "$build_system" in
    *-*-mingw32|*-*-cygwin)
        # Native build
        echo "Detected native build."
        build_type="native"
        build_host=""
        build_host_prefix=""

        ant_home="${ANT_HOME}"
        java_home="${JAVA_HOME}"
        if [ -z "$ant_home" ] ; then
            ant_home=/ant
        fi
        if [ -z "$java_home" ] ; then
            java_home=/java
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
        # Cross build
        echo "Detected cross build."
        build_type="cross"
        build_host=""
        if [ "$build_bits" = "64" ] ; then
            arch=x86_64
        else
            arch=i686
        fi
        for host in $arch-w64-mingw32 $arch-pc-mingw32
        do
            if type $host-gcc >/dev/null 2>&1 ; then
                build_host=$host
                break
            fi
        done
        if [ -n "$build_host" ] ; then
            echo "Detected build prefix: $build_host"
        else
            echo "Couldn't find suitable cross-compiler."
            exit 1
        fi
        build_host_prefix="${build_host}-"
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

# Parse command-line options
parallel=""
build_bits=32
while getopts "j:m:" opt
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
    clean
    ;;
*)
    cat <<EOF

Usage: $0 [-j<n>] [-m{32|64}] {sdist|bdist|clean}
EOF
    exit 1
    ;;
esac
exit 0
