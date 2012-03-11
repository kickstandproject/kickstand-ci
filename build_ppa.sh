#!/bin/sh
# Based on OpenStack's ppa_script.sh
# URL: https://github.com/openstack/openstack-ci

set -e

if [ -z "${PROJECT}" ]; then
	echo '$PROJECT not set.'
	exit 1
fi

BUILD_AREA="../build-area"
PPAS=${PPAS:-builder:$PROJECT-core/trunk}

BUILDNO=1

if ! [ -d ${BUILD_AREA} ]; then
	mkdir -p $BUILD_AREA
fi

./debian/rules get-orig-source

VERSION="$(dpkg-parsechangelog | sed -n -e 's/Version: //p')"
NOEPOCH_VERSION="$(echo ${VERSION} | cut -d':' -f 2)"
PACKAGING_REVNO="$(git log --oneline | wc -l)"

BUILDNO=1
while true
do
	PKGVERSION="${VERSION}~ppa${PACKAGING_REVNO}.${BUILDNO}${SERIES}"
	NOEPOCH_PKGVERSION="${NOEPOCH_VERSION}~ppa${PACKAGING_REVNO}.${BUILDNO}${SERIES}"

	if grep -q "${PROJECT}_${NOEPOCH_PKGVERSION}" ${BUILD_AREA}/*
	then
		echo "We've already built a ${PKGVERSION} of ${PROJECT}. Incrementing build number."
		BUILDNO=$(($BUILDNO + 1))
	else
		break
	fi
done

export DEBFULLNAME="Polybeacon Packaging Team"
export DEBEMAIL="packages@polybeacon.com"
export GPGKEY=1676B27F

SERIES=${SERIES:-precise}

dch -b --force-distribution --v "${PKGVERSION}" "Automated PPA build. Packaging revision: ${PACKAGING_REVNO}." -D $SERIES
git-buildpackage -S --git-ignore-new --git-export=WC

if ! [ "${DO_UPLOAD}" = "no" ]; then
	for ppa in $PPAS; do
		dput --force $ppa "${BUILD_AREA}/${PROJECT}_${NOEPOCH_PKGVERSION}_source.changes"
	done
fi
