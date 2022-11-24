INCLUDE(CheckCSourceCompiles)
INCLUDE(CheckIncludeFiles)
INCLUDE(CheckFunctionExists)
INCLUDE(CheckVariableExists)
INCLUDE(CheckTypeSize)
INCLUDE(CMakeDetermineCCompiler)

OPTION(BUILD_EXTRA_WARNINGS "extra warnings")

# default to ON
set(CMAKE_POSITION_INDEPENDENT_CODE ON CACHE BOOL "Default value for ``POSITION_INDEPENDENT_CODE`` of targets.")

IF(BUILD_EXTRA_WARNINGS)
	SET(WARN_CFLAGS "-g -O2 -g2 -Wall -Wmissing-declarations -Wdeclaration-after-statement -Wcast-align -Wsign-compare -Wnested-externs -Wpointer-arith -Wmissing-prototypes -Wshadow -Wno-pointer-sign -D_FORTIFY_SOURCE=2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security")
	SET(WARN_LDFLAGS "-g -O2 -g2 -Wall -Wl,--as-needed -Wl,--no-undefined")
	# -Werror
ELSE(BUILD_EXTRA_WARNINGS)
	SET(WARN_CFLAGS "")
	SET(WARN_LDFLAGS "")
ENDIF(BUILD_EXTRA_WARNINGS)

IF(CMAKE_COMPILER_IS_GNUCC)
	SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=gnu99 -Wall -g -Wshadow -W -pedantic")
	SET(CMAKE_C_FLAGS_RELEASE        "${CMAKE_C_FLAGS_RELEASE}     -O2")
	SET(CMAKE_C_FLAGS_DEBUG          "${CMAKE_C_FLAGS_DEBUG}       -O0")
	SET(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_WITHDEBINFO} -O2")
	ADD_DEFINITIONS(-D_GNU_SOURCE)
ENDIF(CMAKE_COMPILER_IS_GNUCC)

# awk '/#include <(.*)>/ { h = substr($2,2,length($2)-2); h2=toupper(h); gsub("\\.|\\/", "_", h2); printf "%s%s%s%s%s", "CHECK_INCLUDE_FILES(", h, " HAVE_", h2, ")\n" }' spawn-fcgi.c | sort
CHECK_INCLUDE_FILES(getopt.h HAVE_GETOPT_H)
CHECK_INCLUDE_FILES(pwd.h HAVE_PWD_H)
CHECK_INCLUDE_FILES(sys/wait.h HAVE_SYS_WAIT_H)

CHECK_FUNCTION_EXISTS(issetugid HAVE_ISSETUGID)
CHECK_FUNCTION_EXISTS(inet_pton HAVE_INET_PTON)

CHECK_C_SOURCE_COMPILES("
	#include <sys/types.h>
	#include <sys/socket.h>
	#include <netinet/in.h>
	
	int main() {
		struct sockaddr_in6 s; struct in6_addr t=in6addr_any; int i=AF_INET6; s; t.s6_addr[0] = 0;
		return 0;
	}" HAVE_IPV6)

SET(CMAKE_EXTRA_INCLUDE_FILES sys/socket.h)
CHECK_TYPE_SIZE(socklen_t HAVE_SOCKLEN_T)
SET(CMAKE_EXTRA_INCLUDE_FILES)

## Write out config.h
CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h)

ADD_DEFINITIONS(-DHAVE_CONFIG_H)

INCLUDE_DIRECTORIES(${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR})

ADD_EXECUTABLE(spawn-fcgi spawn-fcgi.c)

SET_TARGET_PROPERTIES(spawn-fcgi PROPERTIES COMPILE_FLAGS ${WARN_CFLAGS})
TARGET_LINK_LIBRARIES(spawn-fcgi ${WARN_LDFLAGS})

INSTALL(TARGETS spawn-fcgi DESTINATION bin)
