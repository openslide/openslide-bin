project(
  'openslide-bin',
  'c',
  version : run_command(
    files('utils/get-version.py'),
    capture : true,
    check : true
  ).stdout().strip(),
  license : 'LGPL-2.1-only',
  meson_version : '>=0.64',
  default_options : [
    'buildtype=plain',
    'default_library=static',
    'wrap_mode=nofallback',
  ],
)

system = host_machine.system()

subdir('deps')
