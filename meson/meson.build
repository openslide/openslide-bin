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

subproject('zlib')
subproject(
  'libffi',
  default_options : [
    'tests=false',
  ],
)
subproject(
  'libxml2',
  default_options : [
    'iconv=disabled',
  ],
)
subproject('sqlite3')

if host_machine.system() != 'linux'
  subproject('proxy-libintl')
endif

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
    'tests=false',
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
    'introspection=disabled',
    'gio_sniffing=false',
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
