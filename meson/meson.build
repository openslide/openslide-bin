project(
  'openslide-winbuild',
  'c',
  license : 'LGPL-2.1-only',
  meson_version : '>=0.64',
)

subproject('zlib')
subproject('libpng')
subproject('libjpeg-turbo')
subproject('libtiff')
subproject(
  'libopenjp2',
  default_options : [
    'build_codec_apps=false',
    'build_doc=disabled',
  ],
)
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
