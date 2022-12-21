#!/bin/bash

SRCTEST=src/spawn-fcgi.c
PACKAGE=spawn-fcgi

# may take one argument for prereleases like
# ./packdist.sh [--nopack] -rc1-r10

tmpdir=$(mktemp --tmpdir -d packdist-XXXXXXX)
trap 'rm -rf "${tmpdir}"' EXIT

if [ ! -f ${SRCTEST} ]; then
	echo "Current directory is not the source directory"
	exit 1
fi

dopack=1
if [ "$1" = "--nopack" ]; then
	dopack=0
	shift
fi

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
		cat ../NEWS | sed "/^- ${version}/,/^-/p;d" | sed "/^- /d;/^$/d" | sed -e 's/^  \*/\*/'
	) > CHANGES
	return 0
}

# genereate links in old textile format "text":url
genlinks_changes() {
	local repourl ticketurl inf out
	repourl="https://redmine.lighttpd.net/projects/spawn-fcgi/repository/revisions/"
	ticketurl="https://redmine.lighttpd.net/issues/show/"
	inf="$1"
	outf="$1".links
	(
		sed -e 's%\(https://[a-zA-Z0-9.:_/\-]\+\)%"\1":\1%g' |
		sed -e 's%#\([0-9]\+\)%"#\1":'"${ticketurl}"'\1%g' |
		sed -e 's%r\([0-9]\+\)%"r\1":'"${repourl}"'\1%g'
	) < "$inf" > "$outf"
}
genlinks_downloads() {
	local repourl ticketurl inf out
	repourl="https://redmine.lighttpd.net/projects/spawn-fcgi/repository/revisions/"
	ticketurl="https://redmine.lighttpd.net/issues/show/"
	inf="$1"
	outf="$1".links
	(
		sed -e 's%\(https://[a-zA-Z0-9.:_/\-]\+\)%"\1":\1%g'
	) < "$inf" > "$outf"
}

if [ ${dopack} = "1" ]; then
	force ./autogen.sh

	if [ -d distbuild ]; then
		# make distcheck may leave readonly files
		chmod u+w -R distbuild
		rm -rf distbuild
	fi

	force mkdir distbuild
	force cd distbuild

	force ../configure --prefix=/usr

	# force make
	# force make check

	force make distcheck
	force make dist-xz
	force make dist-gzip
else
	force cd distbuild
fi

version=`./config.status -V | head -n 1 | cut -d' ' -f3`
name="${PACKAGE}-${version}"

if [ -x "$(which tardiff)" -a -x "$(which git)" ]; then
	force cd ..
	force git archive --format tar.gz -o "${tmpdir}/git-archive.tar.gz" --prefix "${name}/" HEAD
	force cd distbuild

	echo "Diff git -> dist tar"
	force tardiff --modified --autoskip "${tmpdir}/git-archive.tar.gz" "${name}.tar.gz"
fi

downloadbaseurl="https://download.lighttpd.net/spawn-fcgi/releases-1.6.x"
if [ -n "${append}" ]; then
	cp "${name}.tar.xz" "${name}${append}.tar.xz"
	cp "${name}.tar.gz" "${name}${append}.tar.gz"
	name="${name}${append}"
	downloadbaseurl="https://download.lighttpd.net/spawn-fcgi/snapshots-1.6.x"
fi

force sha256sum "${name}.tar."{xz,gz} > "${name}.sha256sum"

rm -f "${name}".tar.*.asc

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
force genlinks_changes CHANGES
force genlinks_downloads DOWNLOADS

cat CHANGES
echo
cat DOWNLOADS

echo
echo -------
echo

cat CHANGES.links
echo
cat DOWNLOADS.links

echo
echo -------
echo

echo wget "${downloadbaseurl}/${name}".'{tar.xz,tar.gz,sha256sum}; sha256sum -c '${name}'.sha256sum'
