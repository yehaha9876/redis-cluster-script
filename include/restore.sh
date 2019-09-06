#!/bin/bash
redis_home="/psr/redis_cluster"
all_server=`cat $redis_home/script/hosts.conf`
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

# check选举是否一致
echo "check选举是否一致"
current_epochs_count=$(for host in $all_server; do
  grep currentEpoch $backup_dir/*.conf
done | awk  '{print $3}' | sort | uniq | wc -l)

if [ $current_epochs_count -ne 1 ]; then
  echo "个节点选举所处时期不一致"
  exit
fi
echo "check选举是否一致, 通过!"

# check rdb 是否全
echo "check rdb 文件个数"
rdb_count=$(for host in $all_server; do
  test -f $backup_dir/redis_dump_17380.rdb && echo "HAVE"
  test -f $backup_dir/redis_dump_17381.rdb && echo "HAVE"
done | wc -l)

if [ $rdb_count -ne 12 ]; then
  echo "rdb 文件数不是12: $rdb_count"
  exit
fi
echo "check rdb 文件个数, 通过!"

if [[ "$backup_dir" != /psr/redis_cluster/data* ]]; then
  echo "复制集群config文件"
  for host in $all_server; do
    echo "!!! ssh $host cp $backup_dir/redis-cluster-nodes-*.conf $redis_home/data/"
    ssh $host "cp $backup_dir/redis-cluster-nodes-*.conf $redis_home/data/"
  done
  echo "复制集群config文件, 完成!"
fi

echo "copy slave rdb文件到指定位置"

config_file=`ls -al $backup_dir/redis-cluster-nodes-*.conf | head -n 1 | awk '{print $9}'`
masters=`grep master $config_file | grep -v fail | sort -k2 | awk '{print $1"&&"$2}'`

for m in $masters; do
{
  m_id=`echo $m | awk -F "&&" '{print $1}'`
  m_ip=`echo $m | awk -F "&&" '{print $2}' | awk -F "@" '{print $1}' | awk -F ":" '{print $1}'`
  mport=`echo $m | awk -F "&&" '{print $2}' | awk -F "@" '{print $1}' | awk -F ":" '{print $2}'`

  s_ip=`grep $m_id $config_file | grep slave | grep -v fail | head -n 1 |awk '{print $2}' | awk -F "@" '{print $1}' | awk -F ":" '{print $1}'`
  sport=`grep $m_id $config_file | grep slave | grep -v fail | head -n 1 | awk '{print $2}' | awk -F "@" '{print $1}' | awk -F ":" '{print $2}'`

  echo "!!! ssh $m_ip scp $s_ip:$redis_home/data/redis_dump_$sport.rdb $redis_home/data/redis_dump_$mport.rdb"
  ssh $m_ip "scp $s_ip:$redis_home/data/redis_dump_$sport.rdb $redis_home/data/redis_dump_$mport.rdb"

  echo "删除data文件夹下的多余rdb文件:redis_dump_$sport.rdb" 
  ssh $s_ip "rm -f $redis_home/data/redis_dump_$sport.rdb"
}&
done
wait

echo "copy slave rdb文件到指定位置, 完成！"

echo "done $(date)"

