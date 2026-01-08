#!/bin/sh

docker rmi -f siscc/dotstatsuite-config:master
docker rmi -f siscc/dotstatsuite-data-viewer:master
docker rmi -f siscc/dotstatsuite-data-lifecycle-manager:master
docker rmi -f siscc/dotstatsuite-data-explorer:master
docker rmi -f siscc/dotstatsuite-share:master
docker rmi -f siscc/dotstatsuite-sdmx-faceted-search:master
docker rmi -f siscc/sdmxri-nsi-maapi:master
docker rmi -f siscc/dotstatsuite-core-transfer:master
docker rmi -f siscc/dotstatsuite-core-auth-management:master
docker rmi -f siscc/dotstatsuite-dbup:master
docker rmi -f siscc/dotstatsuite-keycloak:master

docker images | grep 'siscc\|IMAGE ID' | grep 'master\|IMAGE ID'