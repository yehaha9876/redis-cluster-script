#!/bin/bash
#
## redis backup script
## usage
## redis-backup.sh port backup.dir
redis_home=${1:-"/home/liuhq/bin/redis_cluster"}
backup_to=${2:-"yesterday"}
key_back_count=${3:-3}
AOF="no"

echo "Start backup $(date +'%Y-%m-%d %k:%M:%S')"
running_addr=`ps -fU $(whoami) | grep redis-server | grep cluster | grep -v 'ps -f' | awk '{print $9}'`
if [ -z "$running_addr" ]; then
  echo "No running server"
  echo "End backup $(date +'%Y-%m-%d %k:%M:%S')"
  exit 1
fi

host_arr=($running_addr)
first_host=${host_arr[0]}
self_host=${first_host%:*}

if [ $backup_to = "yesterday" ]; then
  backup_dir="$redis_home/rdb_backup/backup_$(date -d "3 hour ago" +"%Y-%m-%d")/"
else
  backup_dir="$redis_home/rdb_backup/backup_$backup_to/"
fi

test -d $backup_dir || {
  echo "Create backup directory $backup_dir" && mkdir -p $backup_dir
}

# get backup instance
get_cluster_nodes="$redis_home/bin/redis-cli -u redis://$first_host -c cluster nodes"

all_addrs=`$get_cluster_nodes | grep -v fail | grep slave | grep $self_host | awk '{print $2}' | awk -F "@" '{print $1}'`
all_masters=$($get_cluster_nodes | grep -v fail | grep master | grep $self_host | awk -F "@" '{print $1}' | awk '{print $1"@"$2}' )
for id_ip in $all_masters; do 
  id=${id_ip%@*}
  ip_port=${id_ip#*@}
  find=$($get_cluster_nodes | grep -v fail | grep slave | grep $id)
  if [ "$find" == "" ];then
    all_addrs+=" $ip_port"
  fi
done
all_addrs=$(echo $all_addrs)


echo "start backup $all_addrs !!!"
conf="$redis_home/data/redis-cluster-nodes-*.conf"
cp $conf $backup_dir

for addr in $all_addrs; do
  port=${addr#*:}
  cli="$redis_home/bin/redis-cli -u redis://$addr -c"

  rdb="$redis_home/data/redis_dump_$port.rdb"
  aof="$redis_home/data/appendonly_$port.aof"

  # perform a bgsave before copy
  echo bgsave | $cli
  try=720

  while [ $try -gt 0 ] ; do
    ## redis-cli output dos format line feed '\r\n', remove '\r'
    bg=$(echo 'info Persistence' | $cli | awk -F: '/rdb_bgsave_in_progress/{sub(/\r/, "", $0); print $2}')
    ok=$(echo 'info Persistence' | $cli | awk -F: '/rdb_last_bgsave_status/{sub(/\r/, "", $0); print $2}')
    if [ "$bg"aa = "0"aa ] && [ "$ok"aa = "ok"aa ] ; then
      if [ "$AOF" = "no" ]; then
        cp $rdb $backup_dir
      else
        cp $rdb $backup_dir && $aof $backup_dir
      fi

      if [ $? = 0 ] ; then
        echo "[$addr] redis rdb $rdb copied to $backup_dir."

        count=`$cli incr cluster_backing_count`
        ex=`$cli EXPIRE cluster_backing_count 72000`
        break
      else 
        echo "[$addr] >> Failed to copy $rdb to $backup_dir!"

        count=`$cli set cluster_backup_status faild`
        ex=`$cli EXPIRE cluster_backup_status 72000`
        break
      fi
    fi
    try=$((try - 1))
    echo "[$port] redis maybe busy, waiting and retry in 5s..."
    sleep 5

    if [ $try -eq 1 ]; then
      echo "$(date +'%Y-%m-%d %k:%M:%S') rdb dump faild" >> error.log

      stats=`$cli set cluster_backup_status faild`
      ex=`$cli EXPIRE cluster_backup_status 72000`
    fi
  done
done

backup_status=`echo "get cluster_backup_status" | $cli`
if [ "$backup_status" != "faild" ]; then
  backing_count=`$cli get cluster_backing_count`
  slave_count=`echo cluster info | $cli | awk -F: '/cluster_size/{sub(/\r/, "", $0); print $2}'`

  if [ "$backing_count"aa == "$slave_count"aa ]; then
    echo "backup finsih all !!!!"

    ok=`$cli set cluster_backup_status ok`
    ex=`$cli EXPIRE cluster_backup_status 72000`
    del=`$cli del cluster_backing_count`
  fi
fi


# delete rdb created key_back_count days ago
cd $backup_dir/..
echo "delete backup conf before $key_back_count days"
find . \( -name "backup_*" \) -mtime +$key_back_count -exec rm -fr {} \;
echo "End backup $(date +'%Y-%m-%d %k:%M:%S')"

exit 0

