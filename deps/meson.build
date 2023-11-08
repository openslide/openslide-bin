add_global_arguments(
  '-I' + meson.current_source_dir(),
  language: ['c', 'cpp']
)

if system == 'darwin'
  cc = meson.get_compiler('c')
  # [dependency name, library name, version] or
  # [dependency name, library name, header with version, version define]
  overrides = [
    # zlib is handled automatically by dependency()
    # no define for libffi version; pick a value that will pass the checks
    ['libffi', 'ffi', '3.0.0'],
    ['libxml-2.0', 'xml2', 'libxml/xmlversion.h', 'LIBXML_DOTTED_VERSION'],
    ['sqlite3', 'sqlite3', 'sqlite3.h', 'SQLITE_VERSION'],
  ]
  foreach o : overrides
    if o.length() > 3
      version = cc.get_define(
        o[3],
        prefix : '#include <@0@>'.format(o[2])
      ).strip('"')
    else
      version = o[2]
    endif
    meson.override_dependency(
      o[0],
      declare_dependency(
        version : version,
        dependencies : cc.find_library(o[1]),
      )
    )
  endforeach
  # libffi headers are in a subdirectory
  add_global_arguments(
    '-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/ffi',
    language : ['c', 'cpp']
  )
else
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
endif

if system != 'linux'
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
    'quartz=disabled',
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
    '_filter_external_symbols=true',
    'version_suffix=' + get_option('version_suffix'),
    'werror=' + get_option('openslide_werror').to_string(),
  ],
)
subproject(
  'openslide-java',
  default_options : [
    'embed_jni_path=disabled',
    'werror=' + get_option('openslide_werror').to_string(),
  ],
)
