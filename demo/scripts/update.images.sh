#!/bin/sh

docker pull siscc/dotstatsuite-config:master
docker pull siscc/dotstatsuite-data-viewer:master
docker pull siscc/dotstatsuite-data-lifecycle-manager:master
docker pull siscc/dotstatsuite-data-explorer:master
docker pull siscc/dotstatsuite-share:master
docker pull siscc/dotstatsuite-sdmx-faceted-search:master
docker pull siscc/sdmxri-nsi-maapi:master
docker pull siscc/dotstatsuite-core-transfer:master
docker pull siscc/dotstatsuite-core-auth-management:master
docker pull siscc/dotstatsuite-dbup:master
docker pull siscc/dotstatsuite-keycloak:master

docker images | grep 'siscc\|IMAGE ID' | grep 'master\|IMAGE ID'