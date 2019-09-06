#!/bin/sh
redis_home="/psr/redis_cluster"
all_servers=`cat $redis_home/script/hosts.conf`
backup_dir=$(date +'%Y-%m-%d_%H-%M-%S')

for host in $all_servers; do 
{
  echo "server on $host"
  ssh $host "$redis_home/script/include/backup.sh $backup_dir"
}&
done
wait
echo "backup done!"
