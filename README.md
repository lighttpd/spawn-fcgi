
# spawn-fcgi

**authors:** Jan Kneschke, Stefan Bühler

**homepage:** https://redmine.lighttpd.net/projects/spawn-fcgi

**abstract:** spawn-fcgi is used to spawn FastCGI applications

## Features

- binds to IPv4/IPv6 and Unix domain sockets
- supports privilege separation: chmod/chown socket, drop to uid/gid
- supports chroot
- supports daemontools supervise

## Build

[meson](https://mesonbuild.com/) is required to build.

Setup a build directory `build`:

    meson setup build --prefix /usr/local

Compile it:

    meson compile -C build

Install:

    meson install -C build

### Usage

See man page, e.g. [rendered](https://manpages.debian.org/unstable/spawn-fcgi/spawn-fcgi.1.en.html)
for debian unstable.
