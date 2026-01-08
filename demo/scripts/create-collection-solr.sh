#!/bin/sh 

curl -X GET http://localhost:8983/solr/admin/collections?action=CREATE&name=default&numShards=1&collection.configName=_default

