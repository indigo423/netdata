#!/usr/bin/env bash

# docker run -it --rm centos:6.9 /bin/sh
# yum -y install rpm-build redhat-rpm-config yum-utils autoconf automake curl gcc git libmnl-devel libuuid-devel make pkgconfig zlib-devel

cd $(dirname $0)/../../ || exit 1
source "installer/functions.sh" || exit 1

set -e

run ./autogen.sh
run ./configure --enable-maintainer-mode
run make dist

version=$(grep PACKAGE_VERSION < config.h | cut -d '"' -f 2)
if [ -z "${version}" ]
then
    echo >&2 "Cannot find netdata version."
    exit 1
fi

tgz="netdata-${version}.tar.gz"
if [ ! -f "${tgz}" ]
then
	echo >&2 "Cannot find the generated tar.gz file '${tgz}'"
	exit 1
fi

srpm=$(run rpmbuild -ts "${tgz}" | cut -d ' ' -f 2)
if [ -z "${srpm}" -o ! -f "${srpm}" ]
then
	echo >&2 "Cannot find the generated SRPM file '${srpm}'"
	exit 1
fi

run yum-builddep "${srpm}"

run rpmbuild --rebuild "${srpm}"

echo >&2 "All done!"
