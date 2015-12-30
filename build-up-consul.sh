#!/bin/bash

MASTER_NODE='deisNode0'
SLAVE_NODE='deisNode1 deisNode2'


NODE_COUNT=$(echo $MASTER_NODE $SLAVE_NODE | wc -w)

#
# Consul (bootstrap master)
#
cat > docker-compose.yml <<_EOF
consul:
  restart: always
  net: host
  container_name: consul
  image: progrium/consul
  command: "-server -bootstrap-expect $NODE_COUNT"
_EOF

/opt/bin/docker-compose stop
/opt/bin/docker-compose rm -f
/opt/bin/docker-compose up -d

for node in $SLAVE_NODE; do
sleep 10
cat > docker-compose.yml <<_EOF
consul:
  restart: always
  net: host
  container_name: consul
  image: progrium/consul
  command: "-server -join $MASTER_NODE"
_EOF
scp docker-compose.yml $node:
ssh $node /opt/bin/docker-compose stop
ssh $node /opt/bin/docker-compose rm -f
ssh $node /opt/bin/docker-compose up -d
ssh $node rm docker-compose.yml
done

#
# Gorb
#
cat > docker-compose.yml <<_EOF
gorb:
  restart: always
  net: host
  privileged: true
  container_name: gorb
  image: monami0ya/gorb
  command: "-f -i eth0 -c http://localhost:8500/"
_EOF
/opt/bin/docker-compose stop
/opt/bin/docker-compose rm -f
/opt/bin/docker-compose up -d
sleep 10

for node in $MASTER_NODE $SLAVE_NODE; do
cat > docker-compose.yml <<_EOF
gorb-link:
  volumes:
  - "/var/run/docker.sock:/var/run/docker.sock"
  container_name: gorb-link
  image: monami0ya/gorb-docker-link
  command: "-r ${MASTER_NODE}:4672 -i eth0"
_EOF
scp docker-compose.yml $node:
ssh $node /opt/bin/docker-compose stop
ssh $node /opt/bin/docker-compose rm -f
ssh $node /opt/bin/docker-compose up -d
ssh $node rm docker-compose.yml
done

