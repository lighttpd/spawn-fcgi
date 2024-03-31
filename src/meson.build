configure_file(output: 'config.h', configuration: conf_data)

add_project_arguments(
  '-DHAVE_CONFIG_H',
  '-D_GNU_SOURCE',
  '-D_DEFAULT_SOURCE',
  '-D_XOPEN_SOURCE=600',
  language : 'c',
)

bin_worker = executable(
  'spawn-fcgi',
  'spawn-fcgi.c',
  install: true,
  link_with: socket_deps,
)
