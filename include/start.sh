#!/bin/bash
redis_home=$REDIS_HOME
all_server=$CLUSTER_HOSTS

source $redis_home/script/include/helps.sh

if [ "$1" != "master" ] && [ "$1" != "all" ] ; then
  echo "输入启动master或者all"
  exit
fi


# get start ip hosts
start_ip_ports=""
if [ "$1" == "all" ]; then
  start_ip_ports=$(get_not_alive_ip_port)
else
  check_old_file=$(ls $redis_home/data/redis-cluster-nodes-*.conf | wc -l)
  if [ $check_old_file -eq 0 ]; then
    start_ip_ports=$(all_host_ports $1)
  else
    start_ip_ports=$(get_cluster_nodes_from_config | grep $1 | grep -v fail | awk '{print $2}' | awk -F "@" '{print $1}')
  fi
fi
start_ip_ports=$(echo $start_ip_ports)

# start redis server
echo "begin start $1: $start_ip_ports !!!!!"
start_count=0
for ip_port in $start_ip_ports; do
  host=${ip_port%:*}
  port=${ip_port#*:}
  ssh $host "$redis_home/bin/redis-server $redis_home/conf/redis-$port.conf 1>> $redis_home/log/redis_server_$port.log 2>&1;"
  start_count=$(($start_count+1))
done

# 实际启动个数
start_ip_ports_reg=${start_ip_ports// /\\|}
real_count=$(get_alive_process | grep "$start_ip_ports_reg" | wc -l)

echo "start instance count $start_count"
echo "real started instance count $real_count"

if [ $start_count -eq $real_count ]; then
  echo 'start success'
  exit 0
else
  echo 'start faild'
  exit 1
fi

