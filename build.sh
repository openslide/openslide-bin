#!/bin/bash
#
# A script for building OpenSlide and its dependencies for Windows
#
# Copyright (c) 2011-2015 Carnegie Mellon University
# Copyright (c) 2022-2023 Benjamin Gilbert
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

packages="ssp winpthreads zlib libpng libjpeg_turbo libtiff libopenjp2 sqlite3 proxy_libintl libffi pcre2 glib gdk_pixbuf pixman cairo libxml2 openslide openslide_java"

# Package display names
ssp_name="libssp"
winpthreads_name="winpthreads"
zlib_name="zlib"
libpng_name="libpng"
libjpeg_turbo_name="libjpeg-turbo"
libtiff_name="libtiff"
libopenjp2_name="OpenJPEG"
sqlite3_name="SQLite"
proxy_libintl_name="proxy-libintl"
libffi_name="libffi"
pcre2_name="PCRE2"
glib_name="glib"
gdk_pixbuf_name="gdk-pixbuf"
pixman_name="pixman"
cairo_name="cairo"
libxml2_name="libxml2"
openslide_name="OpenSlide"
openslide_java_name="OpenSlide Java"

# Locations of license files within the source tree
ssp_licenses="COPYING3 COPYING.RUNTIME"
winpthreads_licenses="mingw-w64-libraries/winpthreads/COPYING"
zlib_licenses="README"
libpng_licenses="LICENSE"
libjpeg_turbo_licenses="LICENSE.md README.ijg simd/nasm/jsimdext.inc" # !!!
libtiff_licenses="LICENSE.md"
libopenjp2_licenses="LICENSE"
sqlite3_licenses="PUBLIC-DOMAIN.txt"
proxy_libintl_licenses="COPYING"
libffi_licenses="LICENSE"
pcre2_licenses="LICENCE"
glib_licenses="COPYING"
gdk_pixbuf_licenses="COPYING"
pixman_licenses="COPYING"
cairo_licenses="COPYING COPYING-LGPL-2.1 COPYING-MPL-1.1"
libxml2_licenses="Copyright"
# Remove workaround in bdist() when updating these
openslide_licenses="LICENSE.txt lgpl-2.1.txt COPYING.LESSER"
openslide_java_licenses="COPYING.LESSER"

# Build artifacts
ssp_artifacts="libssp-0.dll"
winpthreads_artifacts="libwinpthread-1.dll"
openslide_artifacts="libopenslide-0.dll openslide-quickhash1sum.exe openslide-show-properties.exe openslide-write-png.exe"
openslide_java_artifacts="openslide-jni.dll openslide.jar"

# Update-checking URLs
ssp_upurl="https://mirrors.concertpass.com/gcc/releases/"
winpthreads_upurl="https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/"
zlib_upurl="https://zlib.net/"
libpng_upurl="http://www.libpng.org/pub/png/libpng.html"
libjpeg_turbo_upurl="https://sourceforge.net/projects/libjpeg-turbo/files/"
libtiff_upurl="https://download.osgeo.org/libtiff/"
libopenjp2_upurl="https://github.com/uclouvain/openjpeg/tags"
sqlite3_upurl="https://sqlite.org/changes.html"
proxy_libintl_upurl="https://github.com/frida/proxy-libintl/tags"
libffi_upurl="https://github.com/libffi/libffi/tags"
pcre2_upurl="https://github.com/PCRE2Project/pcre2/tags"
glib_upurl="https://gitlab.gnome.org/GNOME/glib/tags"
gdk_pixbuf_upurl="https://gitlab.gnome.org/GNOME/gdk-pixbuf/tags"
pixman_upurl="https://cairographics.org/releases/"
cairo_upurl="https://cairographics.org/releases/"
libxml2_upurl="https://gitlab.gnome.org/GNOME/libxml2/tags"
openslide_upurl="https://github.com/openslide/openslide/tags"
openslide_java_upurl="https://github.com/openslide/openslide-java/tags"

# Update-checking regexes
ssp_upregex="gcc-([0-9.]+)/"
winpthreads_upregex="mingw-w64-v([0-9.]+)\.zip"
zlib_upregex="source code, version ([0-9.]+)"
libpng_upregex="libpng-([0-9.]+)-README.txt"
libjpeg_turbo_upregex="files/([0-9.]+)/"
libtiff_upregex="tiff-([0-9.]+)\.tar"
libopenjp2_upregex="archive/refs/tags/v([0-9.]+)\.tar"
sqlite3_upregex="[0-9]{4}-[0-9]{2}-[0-9]{2} \(([0-9.]+)\)"
proxy_libintl_upregex="archive/refs/tags/([0-9.]+)\.tar"
libffi_upregex="archive/refs/tags/v([0-9.]+)\.tar"
pcre2_upregex="archive/refs/tags/pcre2-([0-9.]+)\.tar"
glib_upregex="archive/([0-9]+\.[0-9]*[02468]\.[0-9]+)/"
gdk_pixbuf_upregex="archive/([0-9]+\.[0-9]*[02468]\.[0-9]+)/"
pixman_upregex="pixman-([0-9.]+)\.tar"
cairo_upregex="\"cairo-([0-9.]+)\.tar"
libxml2_upregex="archive/v([0-9.]+)/"
openslide_upregex="archive/refs/tags/v([0-9.]+)\.tar"
# Exclude old v1.0.0 tag
openslide_java_upregex="archive/refs/tags/v1\.0\.0\.tar.*|.*archive/refs/tags/v([0-9.]+)\.tar"

# wget standard options
wget="wget -q"


expand() {
    # Print the contents of the named variable
    # $1  = the name of the variable to expand
    echo "${!1}"
}

meson_wrap_key() {
    # $1 = package shortname
    # $2 = file section
    # $3 = file key
    gawk -F ' *= *' \
            -e 'BEGIN {want_section="'$2'"; want_key="'$3'"}' \
            -e 'match($0, /^\[([^]]*)\]$/, out) {section=out[1]}' \
            -e 'section == want_section && $1 == want_key {print $2}' \
            "meson/subprojects/$(echo $1 | tr _ -).wrap"
}

meson_wrap_version() {
    # $1 = package shortname
    local ver
    ver="$(meson_wrap_key $1 wrap-file wrapdb_version)"
    if [ -z "$ver" ]; then
        ver="$(meson_wrap_key $1 wrap-file directory | awk -F - '{print $NF}' | sed 's/^v//')"
    fi
    echo "$ver"
}

override_lock() {
    # Always run this in a subshell!  Lock releases when shell exits.
    # If there are no overrides we can skip the serialization.
    if [ -d override ]; then
        exec 90<>override/.lock
        if ! flock -n 90; then
            echo "Couldn't acquire override lock"
            return 1
        fi
    fi
}

override_init() {
    # Override lock must be held
    local package meson_name
    override_remove
    for package in $packages; do
        if [ -d "override/${package}" ]; then
            echo "Overriding $package..."
            meson_name=$(echo "$package" | tr _ -)
            ln -s "../../override/${package}" \
                    "meson/subprojects/${meson_name}"
            mv "meson/subprojects/${meson_name}.wrap" \
                    "meson/subprojects/${meson_name}.wrap.overridden"
        fi
    done
}

override_remove() {
    # Override lock must be held
    local package meson_name
    for package in $packages; do
        meson_name=$(echo "$package" | tr _ -)
        if [ -L "meson/subprojects/${meson_name}" ]; then
            rm "meson/subprojects/${meson_name}"
        fi
        if [ -e "meson/subprojects/${meson_name}.wrap.overridden" ]; then
            mv "meson/subprojects/${meson_name}.wrap.overridden" \
                    "meson/subprojects/${meson_name}.wrap"
        fi
    done
}

build() {
    if [ ! -f "${build}/compile_commands.json" ]; then
        # If the build directory exists, setup didn't complete last time,
        # and will fail again unless we delete the directory.
        rm -rf "${build}"
    fi
    if [ ! -d "$build" ]; then
        meson setup \
                --buildtype plain \
                --cross-file "meson/cross-win${build_bits}.ini" \
                --wrap-mode nofallback \
                "$build" meson \
                ${ver_suffix:+-Dversion_suffix=${ver_suffix}} \
                ${openslide_werror:+-Dopenslide:werror=true} \
                ${openslide_werror:+-Dopenslide-java:werror=true}
    fi
    meson compile -C "$build" $parallel
    # When building multiple interdependent subpackages, we need to make sure
    # the subpackages aren't accessible in the rootdir on subsequent builds,
    # or else subsequent builds may use a different detection path (system
    # vs. fallback) than the initial build.  Do this by setting prefix to "/"
    # and then using --destdir to install into the real rootdir.
    meson install -C "$build" \
            --only-changed --no-rebuild --destdir "${root}"
    # Move OpenSlide Java artifacts to the right place
    pushd "${root}/lib/openslide-java" >/dev/null
    cp ${openslide_java_artifacts} "${root}/bin/"
    popd >/dev/null
}

sdist() {
    # Build source distribution
    local package file zipdir
    zipdir="openslide-winbuild-${pkgver}"
    rm -rf "${zipdir}"
    meson subprojects download --sourcedir meson
    mkdir -p "${zipdir}/meson/subprojects/packagecache"
    for package in $packages
    do
        cp "meson/subprojects/$(echo $package | tr _ -).wrap" "${zipdir}/meson/subprojects/"
        for file in $(meson_wrap_key $package wrap-file source_filename) \
                $(meson_wrap_key $package wrap-file patch_filename); do
            cp "meson/subprojects/packagecache/$file" \
                    "${zipdir}/meson/subprojects/packagecache/"
        done
        for file in $(meson_wrap_key $package wrap-file diff_files | tr , " "); do
            mkdir -p "${zipdir}/meson/subprojects/packagefiles"
            cp "meson/subprojects/packagefiles/$file" \
                    "${zipdir}/meson/subprojects/packagefiles/"
        done
    done
    mkdir -p "${zipdir}/meson/include"
    cp build.sh Dockerfile.builder README.md COPYING.LESSER "${zipdir}/"
    cp meson/cross-win32.ini meson/cross-win64.ini \
            meson/meson.build meson/meson_options.txt "${zipdir}/meson/"
    cp meson/include/setjmp.h "${zipdir}/meson/include/"
    rm -f "${zipdir}.zip"
    zip -r "${zipdir}.zip" "${zipdir}"
    rm -r "${zipdir}"
}

bdist() {
    # Build binary distribution
    local package name srcdir licensedir zipdir prev_ver_suffix

    # Rebuild OpenSlide if suffix changed
    prev_ver_suffix="$(cat ${build_bits}/.suffix 2>/dev/null ||:)"
    if [ "${ver_suffix}" != "${prev_ver_suffix}" ] ; then
        clean openslide
        mkdir -p "${build_bits}"
        echo "${ver_suffix}" > "${build_bits}/.suffix"
    fi

    (
        override_lock
        override_init
        build
        override_remove
    )

    zipdir="openslide-win${build_bits}-${pkgver}"
    rm -rf "${zipdir}"
    mkdir -p "${zipdir}/bin"
    for package in $packages
    do
        if [ -d "override/${package}" ] ;then
            srcdir="override/${package}"
        else
            srcdir="meson/subprojects/$(meson_wrap_key ${package} wrap-file directory)"
        fi
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
        if [ "$package" = sqlite3 ]; then
            # Extract public-domain dedication from the top of sqlite3.h
            awk '/\*{8}/ {exit} /^\*{2}/ {print}' "${srcdir}/sqlite3.h" > \
                    "${srcdir}/PUBLIC-DOMAIN.txt"
        fi
        for artifact in $(expand ${package}_licenses)
        do
            if ! cp "${srcdir}/${artifact}" "${licensedir}" 2>/dev/null; then
                # OpenSlide license files were renamed; support both until
                # the next release
                if [ "${package}" != openslide ]; then
                    echo "Failed to copy ${artifact} from ${package}."
                    exit 1
                fi
            fi
        done
        if [ "$package" = openslide ]; then
            mkdir -p "${zipdir}/lib"
            cp "${root}/lib/libopenslide.dll.a" "${zipdir}/lib/libopenslide.lib"
            mkdir -p "${zipdir}/include"
            cp -r "${root}/include/openslide" "${zipdir}/include/"
            if [ -f "${srcdir}/README.md" ]; then
                cp "${srcdir}/README.md" "${zipdir}/"
            else
                cp "${srcdir}/README.txt" "${zipdir}/"
            fi
        fi
        printf "%-30s %s\n" "$(expand ${package}_name)" \
                "$(meson_wrap_version ${package})" >> "${zipdir}/VERSIONS.txt"
    done
    rm -f "${zipdir}.zip"
    zip -r "${zipdir}.zip" "${zipdir}"
    rm -r "${zipdir}"
}

clean() {
    # Clean built files
    local package
    if [ $# -gt 0 ] ; then
        for package in "$@"
        do
            echo "Cleaning ${package}..."
            # We don't have a way to remove individual build artifacts
            # right now, so this is just a lighter-weight clean
        done
        rm -rf "${build}"
        grep -Flx "[wrap-redirect]" meson/subprojects/*.wrap | xargs -r rm
        meson subprojects purge --sourcedir meson --confirm >/dev/null
    else
        echo "Cleaning..."
        rm -rf 32 64 openslide-win*-*.zip
        grep -Flx "[wrap-redirect]" meson/subprojects/*.wrap | xargs -r rm
        meson subprojects purge --sourcedir meson --confirm >/dev/null
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
        curver="$(meson_wrap_version $package | cut -f1 -d-)"
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
    build="${build_bits}/build"
    root="$(pwd)/${build_bits}/root"

    if [ "$build_bits" = "64" ] ; then
        build_host=x86_64-w64-mingw32
    else
        build_host=i686-w64-mingw32
    fi
    if ! type ${build_host}-gcc >/dev/null 2>&1 ; then
        echo "Couldn't find suitable compiler."
        exit 1
    fi

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
        openslide_werror=1
        ;;
    esac
done
shift $(( $OPTIND - 1 ))

# Probe build environment
probe

# Clean up any prior Meson overrides, since various subcommands want to
# read wrap files
(
    override_lock
    override_remove
)

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
