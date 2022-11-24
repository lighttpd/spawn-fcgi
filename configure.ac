#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([spawn-fcgi],[1.6.5])
AC_CONFIG_SRCDIR([src/spawn-fcgi.c])
AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([-Wall -Werror foreign])

# Checks for programs.
AC_PROG_CC
AC_PROG_MAKE_SET

dnl @synopsis TRY_CFLAGS [compiler flags]
dnl @summary check whether C compiler supports given flags and adds them to CFLAGS
AC_DEFUN([TRY_CFLAGS],
[dnl
  AC_MSG_CHECKING([if $CC supports $1])
  AC_LANG_PUSH([C])
  ac_try_cflags_saved_cflags="${CFLAGS}"
  CFLAGS="${CFLAGS} $1"
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([])],
    [AC_MSG_RESULT([yes])],
    [
      AC_MSG_ERROR([no])
      # options not supported, remove them:
      CFLAGS="${ac_try_cflags_saved_cflags}"
    ]
  )
  AC_LANG_POP([C])
])

# Checks for libraries.

# Checks for header files.
AC_HEADER_SYS_WAIT
AC_CHECK_HEADERS([getopt.h pwd.h])


# Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_TYPE_UID_T
AC_TYPE_PID_T
AC_CHECK_TYPES(socklen_t,,,[#include <sys/types.h>
#include <sys/socket.h>])

## solaris needs -lsocket -lnsl
AC_SEARCH_LIBS([socket],[socket])
AC_SEARCH_LIBS([inet_addr],[nsl socket])

# Checks for library functions.
AC_CHECK_FUNCS([issetugid inet_pton])

# Check for IPv6 support

AC_ARG_ENABLE(ipv6,
  AS_HELP_STRING([--disable-ipv6],[disable IPv6 support]),
  [case "${enableval}" in
   yes) ipv6=true ;;
    no) ipv6=false ;;
     *) AC_MSG_ERROR(bad value ${enableval} for --enable-ipv6) ;;
  esac],[ipv6=true])

if test x$ipv6 = xtrue; then
  AC_CACHE_CHECK([for IPv6 support], ac_cv_ipv6_support,
    [AC_LINK_IFELSE([AC_LANG_PROGRAM([[
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
    ]], [[
struct sockaddr_in6 s; struct in6_addr t=in6addr_any; int i=AF_INET6; s; t.s6_addr[0] = 0;
    ]])],[ac_cv_ipv6_support=yes],[ac_cv_ipv6_support=no])])

  if test "$ac_cv_ipv6_support" = yes; then
    AC_DEFINE(HAVE_IPV6,1,[Whether to enable IPv6 support])
  fi
fi


# check for extra compiler options (warning options)
if test "${GCC}" = "yes"; then
  TRY_CFLAGS([-Wall -W -Wshadow -pedantic])
  TRY_CFLAGS([-std=gnu99])
fi

AC_ARG_ENABLE([extra-warnings],
 [AS_HELP_STRING([--enable-extra-warnings],[enable extra warnings (gcc specific)])],
 [case "${enableval}" in
   yes) extrawarnings=true ;;
    no) extrawarnings=false ;;
     *) AC_MSG_ERROR([bad value ${enableval} for --enable-extra-warnings]) ;;
  esac],[extrawarnings=false])

if test x$extrawarnings = xtrue; then
  TRY_CFLAGS([-g -O2 -g2 -Wall -Wmissing-declarations -Wdeclaration-after-statement -Wcast-align -Wsign-compare -Wnested-externs -Wpointer-arith -Wmissing-prototypes -Wshadow -Wno-pointer-sign -D_FORTIFY_SOURCE=2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wl,--as-needed -Wl,--no-undefined])
fi

AC_CONFIG_FILES([Makefile src/Makefile doc/Makefile])
AC_OUTPUT
