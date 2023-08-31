project(
  'openslide-winbuild',
  'c',
  license : 'LGPL-2.1-only',
  meson_version : '>=0.64',
  default_options : [
    'default_library=static',
  ],
)

add_global_arguments(
  '-I' + meson.current_source_dir() / 'include',
  language: ['c', 'cpp']
)

# On Fedora the MinGW CRT is built with _FORTIFY_SOURCE so we need to ship
# libssp.  After recent MinGW runtime changes land, this should no longer be
# necessary.
subproject(
  'ssp',
  default_options : [
    'default_library=shared',
  ],
)
subproject(
  'winpthreads',
  default_options : [
    'default_library=shared',
  ],
)
subproject('zlib')
subproject('libpng')
subproject(
  'libjpeg-turbo',
  default_options : [
    # skip the TurboJPEG wrapper
    'jpeg-turbo=disabled',
    'tests=disabled',
  ],
)
subproject('libtiff')
subproject(
  'libopenjp2',
  default_options : [
    'build_codec_apps=false',
    'build_doc=disabled',
  ],
)
subproject('sqlite3')
subproject('proxy-libintl')
subproject(
  'libffi',
  default_options : [
    'tests=false',
  ],
)
subproject(
  'pcre2',
  default_options : [
    'grep=false',
    'test=false',
  ],
)
subproject(
  'glib',
  default_options : [
    'nls=disabled',
  ],
)
subproject(
  'gdk-pixbuf',
  default_options : [
    'png=disabled',
    'tiff=disabled',
    'jpeg=disabled',
    'man=false',
    'builtin_loaders=bmp',
    'installed_tests=false',
  ],
)
subproject(
  'pixman',
  default_options : [
    'openmp=disabled',
    'tests=disabled',
  ],
)
subproject(
  'cairo',
  default_options : [
    'dwrite=disabled',
    'tests=disabled',
  ],
)
subproject(
  'libxml2',
  default_options : [
    'iconv=disabled',
  ],
)
subproject('uthash')
subproject(
  'libdicom',
  default_options : [
    'tests=false',
  ],
)
subproject(
  'openslide',
  default_options : [
    # We don't run tests, but we still check that they build
    'default_library=shared',
    'doc=disabled',
    'version_suffix=' + get_option('version_suffix'),
  ],
)
subproject('openslide-java')
