project(
  'spawn-fcgi',
  'c',
  default_options: [
    'buildtype=debugoptimized',
    'warning_level=3',
    'c_std=gnu99',
  ],
  version: '1.6.6',
  license: 'BSD-3-Clause',
)

compiler = meson.get_compiler('c')

conf_data = configuration_data()
conf_data.set_quoted('PACKAGE_VERSION', meson.project_version())
conf_data.set_quoted('PACKAGE_NAME', meson.project_name())

warn_c_args = [
  '-Wshadow',
  '-W',
  '-pedantic',
]
if get_option('extra-warnings')
  warn_c_args += [
    '-Wmissing-declarations',
    '-Wdeclaration-after-statement',
    '-Wcast-align',
    '-Wsign-compare',
    '-Wnested-externs',
    '-Wpointer-arith',
    '-Wmissing-prototypes',
    '-Wno-pointer-sign',
    '-Wformat',
    '-Wformat-security',
    '-D_FORTIFY_SOURCE=2',
    '-fstack-protector',
    '--param=ssp-buffer-size=4',
  ]
endif

check_sys_includes = [
  'getopt.h',
  'pwd.h',
  'sys/wait.h',
]

check_libc_functions = [
  'issetugid',
  'inet_pton',
]

# run compiler/env checks
foreach sys_include: check_sys_includes
  if compiler.has_header(sys_include)
    conf_data.set10('HAVE_' + sys_include.underscorify().to_upper(), true)
  endif
endforeach
foreach libc_function: check_libc_functions
  if compiler.has_function(libc_function)
    conf_data.set10('HAVE_' + libc_function.underscorify().to_upper(), true)
  endif
endforeach
add_project_arguments(
  compiler.get_supported_arguments(warn_c_args),
  language: 'c'
)

if compiler.has_type(
  'socklen_t',
  prefix: '\n'.join([
    '#include <sys/socket.h>',
  ]),
)
  conf_data.set10('HAVE_SOCKLEN_T', true)
endif

# IPv6 support is mandatory by default
if get_option('ipv6')
  if compiler.has_type(
    'struct sockaddr_in6',
    prefix: '\n'.join([
      '#include <sys/types.h>',
      '#include <sys/socket.h>',
      '#include <netinet/in.h>',
    ]),
  )
    conf_data.set10('HAVE_IPV6', true)
  else
    error('Missing struct sockaddr_in6, needed for IPv6 support')
  endif
endif

# solaris needs -lsocket -lnsl

test_socket_inet_addr_link = '''
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

int main() {
  int s = socket(0, 0, 0);
  in_addr_t a = inet_addr("");
  return 0;
}
'''

if compiler.links(test_socket_inet_addr_link)
  socket_deps = []
else
  socket_deps = [
    compiler.find_library('socket'),
    compiler.find_library('nsl'),
  ]
endif

subdir('src')

install_man(
  'spawn-fcgi.1',
)

summary(
  {
    'ipv6': get_option('ipv6'),
  },
  section: 'Features',
)
