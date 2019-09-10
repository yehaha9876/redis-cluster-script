#!/bin/sh
method=$2
role=$1
redis_home=$REDIS_HOME
all_servers=$CLUSTER_HOSTS

source $redis_home/script/include/helps.sh

if [ "$method" == "" ] || [ "$role" == "" ]; then
  echo "请输入参数1停止种类: master 或 salve"
  echo "请输入参数2停止类型： '1': SHUTDOWN SAVE, '2': SHUTDOWN, '3': kill "
  exit
fi

type=""
if [ $role = "master" ]; then
  type="master"
elif [ $role = "slave" ]; then
  type="slave"
elif [ $role = "all" ]; then
  type=""
else
  echo "请输入参数1停止种类: master 或 salve"
  exit
fi

cmd=""
if [ "$method" == "1" ]; then
  cmd="SHUTDOWN SAVE"
  echo "你输入的是1, SHUTDOWN SAVE"
elif [ "$method" == "2" ]; then
  cmd="SHUTDOWN"
  echo "你输入的是2, SHUTDOWN"
elif [ "$method" == "3" ]; then
  echo "你输入的是3, kill"
else
  echo "请输入停止类型参数， '1': SHUTDOWN SAVE, '2': SHUTDOWN, '3': kill "
  exit
fi

ip_ports=""
if [ "$method" == "3" ] && [ $role = "all" ]; then
  ip_ports=$(all_host_ports)
else
  ip_ports=$(get_cluster_nodes | grep "$type" |sort -k 2 | awk '{print $2}' | awk -F "@" '{print $1}')
fi


if [ $method -eq 1 ] || [ $method -eq 2 ]; then
  # hosts
  echo "shutdown $role !"
  for ip_port in $ip_ports; do 
  {
 	  echo "stop redis server on $ip_port"
  	$redis_home/bin/redis-cli -u redis://$ip_port $cmd
  }&
  done
  wait
else
  for ip_port in $ip_ports; do 
    ip=${ip_port%:*}
    port=${ip_port#*:}
    if [ "$ip" == "" ] || [ "$port" == "" ]; then
      continue
    fi

    echo "kill $ip_port"
    ssh $ip "pgrep redis-server -a | grep ':$port' |awk '{print \$1}' | xargs kill"
  done
fi
echo "stop done"
exit 0
