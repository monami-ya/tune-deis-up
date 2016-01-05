#!/bin/sh

set -e

REPOSITORY=deisNode0:5500

for i in mariadb-galera-data mariadb-galera-conf redis-data mongo-data; do
  docker tag -f tunedeisup_$i ${REPOSITORY}/$i
  docker push ${REPOSITORY}/$i
done
