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

packages="zlib libpng libjpeg_turbo libtiff libopenjp2 sqlite3 proxy_libintl libffi pcre2 glib gdk_pixbuf pixman cairo libxml2 uthash libdicom openslide openslide_java"

# Update-checking URLs
zlib_upurl="https://zlib.net/"
libpng_upurl="http://www.libpng.org/pub/png/libpng.html"
libjpeg_turbo_upurl="https://github.com/libjpeg-turbo/libjpeg-turbo/tags"
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
uthash_upurl="https://github.com/troydhanson/uthash/tags"
libdicom_upurl="https://github.com/ImagingDataCommons/libdicom/tags"
openslide_upurl="https://github.com/openslide/openslide/tags"
openslide_java_upurl="https://github.com/openslide/openslide-java/tags"

# Update-checking regexes
zlib_upregex="source code, version ([0-9.]+)"
libpng_upregex="libpng-([0-9.]+)-README.txt"
libjpeg_turbo_upregex="archive/refs/tags/([0-9.]+)\.tar"
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
uthash_upregex="archive/refs/tags/v([0-9.]+)\.tar"
libdicom_upregex="archive/refs/tags/v([0-9.]+)\.tar"
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

meson_config_key() {
    # $1 = keyfile
    # $2 = file section
    # $3 = file key
    gawk -F ' *= *' \
            -e 'BEGIN {want_section="'$2'"; want_key="'$3'"}' \
            -e 'match($0, /^\[([^]]*)\]$/, out) {section=out[1]}' \
            -e 'section == want_section && $1 == want_key {print $2}' \
            "$1"
}

meson_wrap_key() {
    # $1 = package shortname
    # $2 = file section
    # $3 = file key
    meson_config_key "subprojects/$(echo $1 | tr _ -).wrap" "$2" "$3"
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

tag_cachedir() {
    # $1 = directory path
    if [ ! -e "$1/CACHEDIR.TAG" ]; then
        mkdir -p "$1"
        cat > "$1/CACHEDIR.TAG" <<EOF
Signature: 8a477f597d28d172789f06886806bc55
# This file is a cache directory tag created by openslide-bin.
# For information about cache directory tags, see https://bford.info/cachedir/
EOF
    fi
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
            ln -s "../override/${package}" "subprojects/${meson_name}"
            mv "subprojects/${meson_name}.wrap" \
                    "subprojects/${meson_name}.wrap.overridden"
        fi
    done
}

override_remove() {
    # Override lock must be held
    local package meson_name
    for package in $packages; do
        meson_name=$(echo "$package" | tr _ -)
        if [ -L "subprojects/${meson_name}" ]; then
            rm "subprojects/${meson_name}"
        fi
        if [ -e "subprojects/${meson_name}.wrap.overridden" ]; then
            mv "subprojects/${meson_name}.wrap.overridden" \
                    "subprojects/${meson_name}.wrap"
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
                --cross-file "${cross_file}" \
                "$build" \
                ${ver_suffix:+-Dopenslide:version_suffix=${ver_suffix}} \
                ${openslide_werror}
    fi
    meson compile -C "$build" $parallel
}

sdist() {
    # Build source distribution
    local glib_dir
    meson subprojects purge --confirm >/dev/null
    if [ ! -f "${sbuild}/compile_commands.json" ]; then
        # If the sbuild directory exists, setup didn't complete last time,
        # and will fail again unless we delete the directory.
        rm -rf "${sbuild}"
    fi
    meson setup \
            --cross-file "${cross_file}" \
            "$sbuild" \
            --reconfigure \
            -Dall_subprojects=true
    tag_cachedir 64
    # manually promote gvdb source to avoid 'meson dist' failure
    # https://github.com/mesonbuild/meson/issues/12489
    # delete and recreate for consistency
    rm -rf subprojects/gvdb
    glib_dir="$(meson_wrap_key glib wrap-file directory)"
    cp -a "subprojects/${glib_dir}/subprojects/gvdb" subprojects/
    # avoid spurious complaints about a dirty work tree
    git update-index -q --refresh
    meson dist -C "$sbuild" --formats gztar --include-subprojects --no-tests
    cp "${sbuild}/meson-dist/openslide-bin-${pkgver}.tar.gz" .
}

bdist() {
    # Build binary distribution
    local prev_ver_suffix

    # Rebuild OpenSlide if suffix changed
    prev_ver_suffix="$(cat 64/.suffix 2>/dev/null ||:)"
    if [ "${ver_suffix}" != "${prev_ver_suffix}" ] ; then
        clean openslide
        mkdir -p 64
        echo "${ver_suffix}" > 64/.suffix
    fi

    tag_cachedir 64

    (
        override_lock
        override_init
        build
        override_remove
    )

    cp "${build}/artifacts/openslide-bin-${pkgver}-windows-x64.zip" .
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
        grep -Flx "[wrap-redirect]" subprojects/*.wrap | xargs -r rm
        if [ ! -e suffix ]; then
            meson subprojects purge --confirm >/dev/null
        fi
    else
        echo "Cleaning..."
        rm -rf 64 openslide-bin-*.{tar.gz,zip}
        grep -Flx "[wrap-redirect]" subprojects/*.wrap | xargs -r rm
        if [ ! -e suffix ]; then
            meson subprojects purge --confirm >/dev/null
        fi
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
    if [ ! -e /etc/openslide-winbuild-builder-v1 ] && [ ! -e /etc/openslide-winbuild-builder-v2 ]; then
        echo "Not running in a compatible builder container.  Either build.sh isn't running"
        echo "in the container (see instructions in README.md) or the container image is too"
        echo "old or too new."
        exit 1
    fi

    if [ "${pkg_suffix}" != "-DEFAULT-" ]; then
        export OPENSLIDE_BIN_SUFFIX="${pkg_suffix}"
    else
        export -n OPENSLIDE_BIN_SUFFIX
    fi
    pkgver="$(MESON_SOURCE_ROOT=. python3 utils/get-version.py)"

    if [ -d override/openslide ]; then
        ver_suffix=$(git -C override/openslide rev-parse HEAD | cut -c-7)
    fi

    sbuild=64/sdist
    build=64/build
    cross_file="machines/cross-windows-x64.ini"
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
pkg_suffix="-DEFAULT-"
openslide_werror=""
while getopts "j:wx:" opt
do
    case "$opt" in
    j)
        parallel="-j${OPTARG}"
        ;;
    w)
        openslide_werror="-Dopenslide:werror=true -Dopenslide-java:werror=true"
        ;;
    x)
        pkg_suffix="${OPTARG}"
        ;;
    esac
done
shift $(( $OPTIND - 1 ))

# Clean up any prior Meson overrides, since various subcommands want to
# read wrap files
(
    override_lock
    override_remove
)

# Process command-line arguments
case "$1" in
sdist)
    probe
    sdist
    ;;
bdist)
    probe
    bdist
    ;;
clean)
    probe
    shift
    clean "$@"
    ;;
updates)
    updates
    ;;
version)
    probe
    echo "${pkgver}"
    ;;
*)
    cat <<EOF
Usage: $0 [-x<suffix>] sdist
       $0 [-j<n>] [-w] [-x<suffix>] bdist
       $0 clean [package...]
       $0 updates
       $0 [-x<suffix>] version

Packages:
$packages
EOF
    exit 1
    ;;
esac
exit 0
