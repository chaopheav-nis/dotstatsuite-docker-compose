#!/bin/sh 

echo "Working folder .... : "$1
echo "Replace host to ... : "$2
echo "Replace host from . : "$3
echo "JSON files detected :"
find $1 -type f -name "tenants.json"
find $1 -type f -name "settings.json"

find $1 -type f -name "settings.json" -exec sed -Ei 's#"http://localhost:3004/api"|"http://'$3':3004/api"#"http://'$2':3004/api"#g' {} +

find $1 -type f -name "settings.json" -exec sed -Ei 's#"http://localhost:7002"|"http://'$3':7002"#"http://'$2':7002"#g' {} +

find $1 -type f -name "settings.json" -exec sed -Ei 's#"http://localhost:3005/api"|"http://'$3':3005/api"#"http://'$2':3005/api"#g' {} +

find $1 -type f -name "settings.json" -exec sed -Ei 's#"http://localhost:3005"|"http://'$3':3005"#"http://'$2':3005"#g' {} +

find $1 -type f -name "settings.json" -exec sed -Ei 's#"http://'$3':7001"#"http://'$2':7001"#g' {} +

find $1 -type f -name "tenants.json" -exec sed -Ei 's#"http://'$3'#"http://'$2'#g' {} +

echo "JSON configuration files updated with the following host address: "$2