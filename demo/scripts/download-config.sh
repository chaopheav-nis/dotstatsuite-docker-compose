#!/bin/sh 
rm -rf config/
git clone -c http.sslVerify=false -b master https://gitlab.com/sis-cc/.stat-suite/dotstatsuite-config-data.git config
