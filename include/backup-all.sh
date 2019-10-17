#!/bin/sh
redis_home=$REDIS_HOME
backup_dir=$(date +'%Y-%m-%d_%H-%M-%S')

source $redis_home/script/include/helps.sh
all_servers=$(all_hosts)

for host in $all_servers; do 
{
  echo "server on $host"
  ssh $host "bash $redis_home/script/backup.sh $redis_home $backup_dir"
}&
done
wait
echo "backup done!"
