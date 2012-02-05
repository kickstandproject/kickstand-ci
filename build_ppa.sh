#!/bin/sh

set -e

if [ -z "${PROJECT}" ]; then
	echo '$PROJECT not set.'
	exit 1
fi

BUILD_AREA=build-area
PPAS=${PPAS:-builder:$PROJECT-core/trunk}
SERIES=${SERIES:-precise}
BUILDNO=1

mkdir -p $BUILD_AREA

cd ${PROJECT}
VERSION="$(dpkg-parsechangelog | sed -n -e 's/Version: //p')"
NOEPOCH_VERSION="$(echo ${VERSION} | cut -d':' -f 2)"
PACKAGING_REVNO="$(git log --oneline | wc -l)"
PKGVERSION="${VERSION}~ppa${PACKAGING_REVNO}~${SERIES}${BUILDNO}"
NOEPOCH_PKGVERSION="${NOEPOCH_VERSION}~ppa${PACKAGING_REVNO}~${SERIES}${BUILDNO}"

./debian/rules get-orig-source

export DEBFULLNAME="Polybeacon Packaging Team"
export DEBEMAIL="packages@polybeacon.com"
export GPGKEY=1676B27F

dch -b --force-distribution --v "${PKGVERSION}" "Automated PPA build. Packaging revision: ${PACKAGING_REVNO}." -D $SERIES
git-buildpackage -S --git-ignore-new --git-export=WC

if ! [ "${DO_UPLOAD}" = "no" ]; then
	for ppa in $PPAS
	do
		dput --force $ppa "../${BUILD_AREA}/${PROJECT}_${NOEPOCH_PKGVERSION}_source.changes"
	done
fi
cd ..
