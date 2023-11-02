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
]
