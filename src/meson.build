configure_file(output: 'config.h', configuration: conf_data)

bin_worker = executable(
  'spawn-fcgi',
  'spawn-fcgi.c',
  install: true,
  link_with: socket_deps,
)
