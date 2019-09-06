#!/bin/sh
redis_home=${1:-"/psr/redis_cluster"}
all_servers=`cat $redis_home/script/hosts.conf`

for host in $all_servers; do 
  echo "server on $host"
  ssh $host "ps -fU $(whoami) | grep redis-server | grep cluster | grep -v 'ps -f'"
done
