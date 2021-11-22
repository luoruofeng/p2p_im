#!/bin/bash

echo 开始构建...

coturn=`docker ps -a | grep coturn`
p2pserver=`docker ps -a | grep p2pserver`

if [[ -n $coturn ]];then
  echo 1
  echo $coturn
  docker stop coturn
  docker rm coturn
fi

if [[ -n $p2pserver ]];then
  echo 1
  echo $p2pserver
  docker stop p2pserver
  docker rm p2pserver
fi

imnet=`docker network ls | grep p2pim-net`
if [[ -n $imnet ]];then
  docker network rm p2pim-net
  docker network create --driver bridge --subnet 172.22.16.0/24 p2pim-net
fi

docker run -d --network=host --name=coturn --restart=always coturn/coturn \
            -n --log-file=stdout \
            --min-port=49160 --max-port=49200 \
            --listening-port=3478 \
            --external-ip=192.168.43.42 \
            --user=luoruofeng:123456 \
            --realm=192.168.43.42


docker build -t p2p-im:v1.0 .

docker run --network=p2pim-net --name p2pserver -p 80:80 -p 443:443 -d --restart=always p2p-im:v1.0 &

echo 完成.