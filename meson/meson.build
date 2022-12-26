project(
  'openslide-winbuild',
  'c',
  license : 'LGPL-2.1-only',
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
