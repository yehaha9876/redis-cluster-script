#!/bin/sh
redis_home=$REDIS_HOME
all_servers=$CLUSTER_HOSTS
backup_dir=$(date +'%Y-%m-%d_%H-%M-%S')

for host in $all_servers; do 
{
  echo "server on $host"
  ssh $host "bash $redis_home/script/backup.sh $redis_home $backup_dir"
}&
done
wait
echo "backup done!"
