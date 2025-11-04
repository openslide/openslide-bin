py_config = {
  'version' : meson.project_version(),
}

py_artifacts = [
  configure_file(
    configuration : py_config,
    input : '__init__.in.py',
    output : '__init__.py',
  ),
  custom_target(
    command : [find_program('../write-pyproject.py'), '@INPUT@', '@OUTPUT@'],
    input : 'pyproject.in.toml',
    output : 'pyproject.toml',
    # ensure we regenerate after dependency updates and version bumps
    build_always_stale : true,
    env : env,
  ),
  files(meson.project_source_root() / 'COPYING.LESSER', 'py.typed'),
  libopenslide_postprocessed,
  licenses,
]
