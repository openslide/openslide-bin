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

subproject(
  'pcre2',
  default_options : [
    'grep=false',
    'test=false',
    'jit_sealloc=disabled',# arm64 darwin
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
subproject('libtiff', default_options: [
  # 'webp=disabled', # for arm64 darwin
  # 'lzma=disabled', # arm64 darwin, fixed by removing xz from homebrew
  # 'zstd=disabled', # not sure, probably arm64 darwin
])
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
  'libxml2',
  default_options : [
    'iconv=disabled',
    # 'lzma=disabled', # arm64 darwin, fixed by removing xz from homebrew
  ],
)
if host_machine.system() != 'linux'
  subproject(
    'glib',
    default_options : [
      'nls=disabled',
      'selinux=disabled',
      'libmount=disabled'
    ],
  )
endif
subproject(
  'gdk-pixbuf',
  default_options : [
    'png=enabled',
    'tiff=enabled',
    'jpeg=enabled',
    'man=false',
    'builtin_loaders=all',
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

