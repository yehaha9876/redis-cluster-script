#!/bin/bash
redis_home="/psr/redis_cluster"
all_server=`cat $redis_home/script/hosts.conf`
cluster_count=0
if [ "$1" != "master" ] && [ "$1" != "slave" ] ; then
  echo "输入启动master还是slave"
  exit
fi

if [ "$1" = "master" ]; then
  echo "begin start master !!!!!"
  for host in $all_server; do
  #ssh $host "cd /psr/redis_cluster/conf; sed -i \"s@^cluster-node-timeout .*@cluster-node-timeout 800000@\" *.conf"

  ssh $host > /dev/null 2>&1 << eeooff
cd /psr/redis_cluster/bin;
/psr/redis_cluster/bin/redis-server /psr/redis_cluster/conf/redis-16380.conf 1>> /psr/redis_cluster/log/redis_server_16380.log 2>&1;
/psr/redis_cluster/bin/redis-server /psr/redis_cluster/conf/redis-16381.conf 1>> /psr/redis_cluster/log/redis_server_16381.log 2>&1;
eeooff
  cluster_count=$(($cluster_count+2))
  done
elif [ "$1" = "slave" ]; then
  echo "begin start salve !!!!!"
  for host in $all_server; do
  #ssh $host "cd /psr/redis_cluster/conf; sed -i \"s@^cluster-node-timeout .*@cluster-node-timeout 800000@\" *.conf"

ssh $host > /dev/null 2>&1 << eeooff
cd /psr/redis_cluster/bin;
/psr/redis_cluster/bin/redis-server /psr/redis_cluster/conf/redis-17380.conf 1>> /psr/redis_cluster/log/redis_server_17380.log 2>&1;
/psr/redis_cluster/bin/redis-server /psr/redis_cluster/conf/redis-17381.conf 1>> /psr/redis_cluster/log/redis_server_17381.log 2>&1;
eeooff
  cluster_count=$(($cluster_count+2))
  done
fi

#cd /psr/redis_cluster/conf; sed -i \"s@^cluster-node-timeout 500000@cluster-node-timeout 5000@\" *.conf
port=1638
if [ "$1" = "slave" ]; then
  port=1738
fi
# 实际启动个数
real_count=`for host in $all_server; do ssh $host "ps -fU $(whoami) | grep redis-server | grep cluster | grep '$port' | grep -v 'ps -f'"; done | wc -l`

echo "start instance count $cluster_count"
echo "real started instance count $real_count"

if [ $cluster_count -eq $real_count ]; then
  echo 'start success'
  exit 0
else
  echo 'start faild'
  exit 1
fi

