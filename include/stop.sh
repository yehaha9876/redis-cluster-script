#!/bin/sh
method=$2
role=$1
redis_home="/psr/redis_cluster"
all_servers=`cat $redis_home/script/hosts.conf`

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

alive_instans=$(for host in $all_servers; do
  ssh $host "ps -fU \$(whoami) | grep redis-server | grep cluster | grep -v 'ps -f' | awk '{print \$9}'"
done | head -n 1)

if [ "$alive_instans" == "" ]; then
   echo "no instans !!!"
   exit
fi
echo $alive_instans

ip_ports=$($redis_home/bin/redis-cli -u redis://$alive_instans -c cluster nodes | grep $type |sort -k 2 | awk '{print $2}' | awk -F "@" '{print $1}')

if [ $method -eq 1 ] || [ $method -eq 2 ]; then

  # hosts
  echo "shutdown $type !"
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

    redis_pid=$(ssh $ip "ps -fU \$(whoami) | grep redis-server | grep cluster | grep -v 'ps -f' | grep \"$port\" | awk '{print \$2}'")
    if [ "$redis_pid" != "" ]; then
      echo "server pid: $redis_pid on $ip to kill"
      ssh $ip "kill -9 $redis_pid"
    fi
  done
fi
echo "stop done"
exit 0
