#!/bin/bash
redis_home=$REDIS_HOME
all_server=$CLUSTER_HOSTS

source $redis_home/script/include/helps.sh

if [ "$1" == "" ]; then
  echo "请传入备份文件所在位置, 例如：/psr/redis_cluster/backup/backup_2018-11-16"
  exit
fi

echo "begin $(date)"

# 检测备份文件
backup_dir="$1"
test -d $backup_dir || {
   echo "本机上没有对应日期文件夹: $backup_dir"
}

# check rdb 是否全
echo "check rdb 文件个数"
rdb_count=$(for host in $all_server; do
  ls $backup_dir/redis_dump_*.rdb
done | wc -l)

less_count=$(all_host_ports "master" | wc -l)
if [ $rdb_count -lt $less_count ]; then
  echo "rdb 文件数少于最少需求: $rdb_count"
  exit
fi
echo "check rdb 文件个数, 通过!"

if [ "$backup_dir" != "$redis_home/data" ]; then
  echo "复制集群config文件, 清理文件"
  for host in $all_server; do
    echo "!!! ssh $m_ip rm -f $redis_home/data/redis_dump_*.rdb"
    ssh $host "rm -f $redis_home/data/redis_dump_*.rdb"

    echo "!!! ssh $host cp $backup_dir/redis-cluster-nodes-*.conf $redis_home/data/"
    ssh $host "cp $backup_dir/redis-cluster-nodes-*.conf $redis_home/data/"
  done
  echo "复制集群config文件, 完成!"
fi
echo "copy slave rdb文件到指定位置"

masters=$(get_cluster_nodes_from_config | grep -v fail | grep master | sort -k2 | awk '{print $1"&&"$2}')
for m in $masters; do
{
  m_id=`echo $m | awk -F "&&" '{print $1}'`
  m_ip=`echo $m | awk -F "&&" '{print $2}' | awk -F "@" '{print $1}' | awk -F ":" '{print $1}'`
  mport=`echo $m | awk -F "&&" '{print $2}' | awk -F "@" '{print $1}' | awk -F ":" '{print $2}'`

  s_ip_port=`get_cluster_nodes_from_config | grep $m_id | grep slave | grep -v fail | head -n 1 |awk '{print $2}' | awk -F "@" '{print $1}'`
  if [ "$s_ip_port" != "" ]; then
    s_ip=${s_ip_port%:*}
    sport=${s_ip_port#*:}
    echo "!!! ssh $m_ip scp $s_ip:$backup_dir/redis_dump_$sport.rdb $redis_home/data/redis_dump_$mport.rdb"
    ssh $m_ip "scp $s_ip:$backup_dir/redis_dump_$sport.rdb $redis_home/data/redis_dump_$mport.rdb"
  else
    echo "!!! ssh $m_ip cp $backup_dir/redis_dump_$mport.rdb $redis_home/data/redis_dump_$mport.rdb"
    ssh $m_ip "cp $backup_dir/redis_dump_$mport.rdb $redis_home/data/redis_dump_$mport.rdb"
  fi
}&
done
wait

echo "copy slave rdb文件到指定位置, 完成！"

echo "done $(date)"

