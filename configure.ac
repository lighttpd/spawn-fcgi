#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.61)
AC_INIT([spawn-fcgi],[1.6.0])
AC_CONFIG_SRCDIR([src/spawn-fcgi.c])
AC_CONFIG_HEADER([config.h])

AM_INIT_AUTOMAKE([-Wall -Werror foreign])

# Checks for programs.
AC_PROG_CC
AC_PROG_MAKE_SET

# Checks for libraries.

# Checks for header files.
AC_HEADER_STDC
AC_HEADER_SYS_WAIT
AC_CHECK_HEADERS([arpa/inet.h errno.h fcntl.h getopt.h grp.h netdb.h \
                  netinet/in.h netinet/tcp.h pwd.h stdio.h stdlib.h \
                  string.h sys/ioctl.h sys/socket.h sys/stat.h sys/time.h \
                  sys/types.h sys/un.h sys/wait.h unistd.h])


# Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_TYPE_PID_T
AC_HEADER_TIME
AC_CHECK_TYPES(socklen_t,,,[#include <sys/types.h>
#include <sys/socket.h>])

# Checks for library functions.
AC_FUNC_FORK
AC_FUNC_MALLOC
AC_FUNC_SELECT_ARGTYPES
AC_FUNC_STAT
AC_CHECK_FUNCS([dup2 memset putenv select socket strerror strtol])

AC_CONFIG_FILES([Makefile src/Makefile])
AC_OUTPUT
