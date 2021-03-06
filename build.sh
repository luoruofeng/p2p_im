#!/bin/bash

echo 开始构建...

coturn=`docker ps -a | grep coturn`
p2pserver=`docker ps -a | grep p2pserver`
p2pimage=`docker images | grep p2p-im`
imnet=`docker network ls | grep p2pim-net`

if [[ -n $coturn ]];then
  echo 删除conturn容器
  docker stop coturn
  docker rm coturn
fi

if [[ -n $p2pserver ]];then
  echo 删除p2pserver容器
  docker stop p2pserver
  docker rm p2pserver
fi

if [[ -n $p2pimage ]];then
  echo 删除p2p-im镜像
  docker rmi p2p-im:v1.0
fi

if [[ -n $imnet ]];then
  echo 删除p2pim-net网络
  docker network rm p2pim-net
fi

echo 创建p2pim-net网络
docker network create --driver bridge p2pim-net

echo 运行coturn容器
docker run -d --network=host --name=coturn --restart=always coturn/coturn \
            -n --log-file=stdout \
            --min-port=49160 --max-port=49200 \
            --listening-port=3478 \
            --external-ip=116.62.22.251  \
            --user=luoruofeng:123456 \
            --realm=hbox.video

echo 创建p2p-im镜像
docker build -t p2p-im:v1.0 .

echo 运行p2pserver容器
docker run --network=p2pim-net --name p2pserver -p 80:80 -p 443:443 -d --restart=always p2p-im:v1.0 &

echo 完成.