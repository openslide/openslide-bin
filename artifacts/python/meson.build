py_config = {
  'version' : meson.project_version(),
}

py_artifacts = [
  configure_file(
    configuration : py_config,
    input : 'pyproject.in.toml',
    output : 'pyproject.toml',
  ),
  configure_file(
    configuration : py_config,
    input : '__init__.in.py',
    output : '__init__.py',
  ),
  files('py.typed'),
  libopenslide_postprocessed,
  licenses,
]
