# should we enable all subprojects that are needed by any OS?  this is
# needed when building source distributions so we don't leave anything out
all_systems = get_option('all_systems')
# should we enable subprojects needed by OpenSlide Git main?
dev_deps = get_option('dev_deps')

add_global_arguments(
  '-I' + meson.current_source_dir(),
  language : ['c', 'cpp'],
)

if not all_systems and system == 'darwin'
  cc = meson.get_compiler('c')
  # [dependency name, library name, version] or
  # [dependency name, library name, header with version, version define]
  overrides = [
    # no define for libffi version; pick a value that will pass the checks
    ['libffi', 'ffi', '3.0.0'],
    ['libxml-2.0', 'xml2', 'libxml/xmlversion.h', 'LIBXML_DOTTED_VERSION'],
    ['sqlite3', 'sqlite3', 'sqlite3.h', 'SQLITE_VERSION'],
  ]
  foreach o : overrides
    if o.length() > 3
      version = cc.get_define(
        o[3],
        prefix : '#include <@0@>'.format(o[2]),
      ).strip('"')
    else
      version = o[2]
    endif
    meson.override_dependency(
      o[0],
      declare_dependency(
        version : version,
        dependencies : cc.find_library(o[1]),
      ),
    )
  endforeach
  # libffi headers are in a subdirectory
  add_global_arguments(
    '-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/ffi',
    language : ['c', 'cpp'],
  )
endif

# ignore SDK zlib on macOS (except as a dependency of the other SDK libs)
meson.override_dependency(
  'zlib',
  subproject(
    'zlib-ng',
    default_options : ['tests=disabled', 'zlib-compat=true'],
  ).get_variable('zlib_ng_dep'),
)

if all_systems or system != 'darwin'
  subproject(
    'libffi',
    default_options : ['tests=false'],
  )
  subproject(
    'libxml2',
    default_options : ['iconv=disabled', 'python=disabled'],
  )
  subproject(
    'sqlite3',
    default_options : ['all-extensions=disabled'],
  )
endif

if all_systems or system != 'linux'
  subproject('proxy-libintl')
endif

if dev_deps
  subproject(
    'zstd',
    default_options : ['bin_programs=false'],
  )
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
  default_options : ['build_codec_apps=false'],
)
subproject(
  'pcre2',
  default_options : ['grep=false', 'test=false'],
)
subproject(
  'glib',
  default_options : [
    'introspection=disabled',
    'nls=disabled',
    'tests=false',
    'glib_debug=disabled',
  ],
)
subproject(
  'gdk-pixbuf',
  default_options : [
    'png=disabled',
    'tiff=disabled',
    'jpeg=disabled',
    'gif=disabled',
    'others=enabled',
    'man=false',
    'builtin_loaders=bmp',
    'introspection=disabled',
    'gio_sniffing=false',
    'tests=false',
  ],
)
subproject(
  'pixman',
  default_options : ['demos=disabled', 'openmp=disabled', 'tests=disabled'],
)
subproject(
  'cairo',
  default_options : ['dwrite=disabled', 'quartz=disabled', 'tests=disabled'],
)
subproject('uthash')
subproject(
  'libdicom',
  default_options : ['tests=false'],
)
openslide = subproject(
  'openslide',
  default_options : [
    # We don't run tests, but we still check that they build
    'default_library=shared',
    'doc=disabled',
  ],
)
