env = environment()
env.prepend('PYTHONPATH', meson.project_source_root())
# Meson doesn't pass MESONINTROSPECT to custom targets
# https://github.com/mesonbuild/meson/issues/12492
mesonintrospect = run_command(
  files('get-introspect-command.py'),
  capture : true,
  check : true,
).stdout().strip()
env.set('MESONINTROSPECT', mesonintrospect)
# nor MESON_SOURCE_ROOT
env.set('MESON_SOURCE_ROOT', meson.project_source_root())
env.set('LD', find_program('ld').full_path())
if system == 'linux'
  env.set('PATCHELF', find_program('patchelf').full_path())
endif
if system == 'darwin'
  env.set('DSYMUTIL', find_program('dsymutil').full_path())
  env.set('DYLD_INFO', find_program('dyld_info').full_path())
  env.set('INSTALL_NAME_TOOL', find_program('install_name_tool').full_path())
  env.set('OTOOL', find_program('otool').full_path())
  env.set('STRIP', find_program('strip').full_path())
else
  env.set('OBJCOPY', find_program('objcopy').full_path())
  env.set('OBJDUMP', find_program('objdump').full_path())
endif

fs = import('fs')
openslide_jar = openslide_java.get_variable('openslide_jar')
artifact_dir = get_option('prefix') / 'artifacts'
artifacts = [
  custom_target(
    command : [find_program('write-project-versions.py'), '-o', '@OUTPUT@'],
    output : 'VERSIONS.md',
    # ensure we regenerate after dependency updates
    build_always_stale : true,
    env : env,
    install : true,
    install_dir : get_option('datadir'),
  ),
  custom_target(
    command : ['cp', '@INPUT@', '@OUTPUT@'],
    input : openslide_jar,
    output : fs.name(openslide_jar.full_path()),
    install : true,
    install_dir : artifact_dir,
  ),
]

libopenslide = openslide.get_variable('libopenslide')
if system == 'windows'
  artifacts += custom_target(
    command : [
      find_program('write-import-library.py'), '@INPUT@', '@OUTPUT@'
    ],
    input : libopenslide,
    output : 'libopenslide.lib',
    env : env,
    install : true,
    install_dir : artifact_dir,
  )
endif

postprocess = find_program('postprocess-binary.py')
foreach bin : [
  libopenslide,
  openslide.get_variable('slidetool'),
  openslide_java.get_variable('openslide_jni'),
]
  name = fs.name(bin.full_path())
  artifacts += custom_target(
    command : [postprocess, '@INPUT@', '-o', '@OUTPUT0@', '-d', '@OUTPUT1@'],
    input : bin,
    output : [name, name + (system == 'darwin' ? '.dSYM' : '.debug')],
    env : env,
    install : true,
    install_dir : artifact_dir,
  )
endforeach
