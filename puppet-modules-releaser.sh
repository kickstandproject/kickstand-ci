#!/bin/sh

set -e

VERSION="$(grep version Modulefile | cut -d' ' -f 2 | sed -e "s/'//g")"
MAJOR="$(echo ${VERSION} | cut -d '.' -f 1)"
MINOR="$(echo ${VERSION} | cut -d '.' -f 2)"
MAINTENANCE="$(echo ${VERSION} | cut -d '.' -f 3)"
VERSIONBUMP="${MAJOR}.${MINOR}.$((${MAINTENANCE} + 1))"

git tag -u 6E14C2BE v${VERSION} -m "Release v${VERSION}"

sed -i "s/'${VERSION}'/'${VERSIONBUMP}'/g" Modulefile

git commit -a -s -m "Bump module version to ${VERSIONBUMP}"
git push
git push --tags
