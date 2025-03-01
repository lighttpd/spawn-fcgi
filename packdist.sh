#!/bin/bash

# may take one argument for prereleases like
# ./packdist.sh [--nopack] -rc1-r10

builddir=distbuild
tmpdir=$(mktemp --tmpdir -d packdist-XXXXXXX)
trap 'rm -rf "${tmpdir}"' EXIT

append="$1"

force() {
	"$@" || {
		echo "Command failed: $*"
		exit 1
	}
}

# summarize all changes since last release
genchanges() {
	(
		echo "h1. Changes"
		echo
		cat "${self}/NEWS" | sed "/^- ${version}/,/^-/p;d" | sed "/^- /d;/^$/d" | sed -e 's/^  \*/\*/'
	) > CHANGES
	return 0
}

self=$(dirname "$(readlink -f "$0")")
force cd "${self}"

if [ -d "${builddir}" ]; then
	# make distcheck may leave readonly files
	chmod u+w -R "${builddir}"
	rm -rf "${builddir}"
fi

force meson setup "${builddir}"
# meson dist ensures tree isn't dirty, and also compiles/tests
force meson dist -C "${builddir}" --formats gztar

package=$(meson introspect "${builddir}" --projectinfo | jq -r '.descriptive_name')
version=$(meson introspect "${builddir}" --projectinfo | jq -r '.version')
name="${package}-${version}"

if [ -z "${package}" -o -z "${version}" ]; then
	echo >&2 "Failed extracting package name and/or version"
	exit 1
fi

# meson dist isn't reproducable (meson offers dist hooks and probably uses current time;
# git archive uses timestamps from git commit).
# so use git archive instead of meson dist, but show tardiff (should be empty; timestamps not shown).
# (still use meson dist for compile/tests run)

force git archive --format tar -o "${builddir}/${name}.tar" --prefix "${name}/" HEAD
force gzip -n --keep "${builddir}/${name}.tar"
force xz --keep "${builddir}/${name}.tar"
force rm "${builddir}/${name}.tar"

echo "Diff git -> meson dist tar.gz"
force tardiff --modified --autoskip "${builddir}/${name}.tar.gz" "${builddir}/meson-dist/${name}.tar.gz"

force cd "${builddir}"

downloadbaseurl="https://download.lighttpd.net/spawn-fcgi/releases-1.6.x"
if [ -n "${append}" ]; then
	cp "${name}.tar.xz" "${name}${append}.tar.xz"
	cp "${name}.tar.gz" "${name}${append}.tar.gz"
	name="${name}${append}"
	downloadbaseurl="https://download.lighttpd.net/spawn-fcgi/snapshots-1.6.x"
fi

force sha256sum "${name}.tar."{xz,gz} > "${name}.sha256sum"

force gpg -a --output "${name}.tar.xz.asc" --detach-sig "${name}.tar.xz"
force gpg -a --output "${name}.tar.gz.asc" --detach-sig "${name}.tar.gz"

(
	echo "h1. Downloads"
	echo
	echo "* ${downloadbaseurl}/${name}.tar.xz"
	echo "** GPG signature: ${downloadbaseurl}/${name}.tar.xz.asc"
	echo "** SHA256: @$(sha256sum ${name}.tar.xz | cut -d' ' -f1)@"
	echo "* SHA256 checksums: ${downloadbaseurl}/${name}.sha256sum"
	echo "* ${downloadbaseurl}/${name}.tar.gz"
	echo "** GPG signature: ${downloadbaseurl}/${name}.tar.gz.asc"
	echo "** SHA256: @$(sha256sum ${name}.tar.gz | cut -d' ' -f1)@"
) > DOWNLOADS

force genchanges

echo -------
cat CHANGES
echo
cat DOWNLOADS
echo -------

echo "scp ${builddir}/${name}.{tar*,sha256sum} lighttpd.net:..."
echo wget "${downloadbaseurl}/${name}".'{tar.xz,tar.gz,sha256sum}; sha256sum -c '${name}'.sha256sum'
