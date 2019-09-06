#!/bin/sh
redis_home="/psr/redis_cluster"
all_servers=`cat $redis_home/script/hosts.conf`

for host in $all_servers; do 
  echo "server on $host"
  #ssh root@$host "mkdir /psr/redis_cluster; chown -R psr_redis_1:psr_redis_1 /psr/redis_cluster"
  #scp -r /psr/redis_cluster/* $host:/psr/redis_cluster
  #ssh $host "cp -rp /psr/redis_cluster /psr"
  #ssh $host "du -sh /psr/redis_cluster"
  #ssh $host "cd /psr/redis_cluster/script; sed -i \"s@/data1/redis_cluster@/psr/redis_cluster@\" *.sh"
  #ssh $host "cd /psr/redis_cluster/script/include; sed -i \"s@/data1/redis_cluster@/psr/redis_cluster@\" *.sh"
  #ssh $host "cd /psr/redis_cluster/conf; sed -i \"s@/data1/redis_cluster@/psr/redis_cluster@\" *.conf"
  #ssh $host "cd /psr/redis_cluster/script; sed -i \"s@/data1/redis_cluster@/psr/redis_cluster@\" *.conf"
  #ssh $host "rm -f /psr/redis_cluster/conf/*.conf"
  #scp -r /psr/redis_cluster/* $host:/psr/redis_cluster
  #ssh $host "cd /psr/redis_cluster/conf; sed -i \"s@^maxmemory 60gb@maxmemory 70gb@\" *.conf"

  
  #scp  /psr/redis_cluster/conf/*.conf $host:/psr/redis_cluster/conf
  #ssh $host "mv /psr/redis_cluster/data/redis-cluster-nodes-16480.conf /psr/redis_cluster/data/redis-cluster-nodes-16380.conf"
  #ssh $host "mv /psr/redis_cluster/data/redis-cluster-nodes-16481.conf /psr/redis_cluster/data/redis-cluster-nodes-16381.conf"

  #ssh $host "mv /psr/redis_cluster/data/redis-cluster-nodes-16580.conf /psr/redis_cluster/data/redis-cluster-nodes-17380.conf"
  #ssh $host "mv /psr/redis_cluster/data/redis-cluster-nodes-16581.conf /psr/redis_cluster/data/redis-cluster-nodes-17381.conf"


  #ssh $host "mv /psr/redis_cluster/data/redis_dump_16480.rdb /psr/redis_cluster/data/redis_dump_16380.rdb"
  #ssh $host "mv /psr/redis_cluster/data/redis_dump_16481.rdb /psr/redis_cluster/data/redis_dump_16381.rdb"

  #ssh $host "mv /psr/redis_cluster/data/redis_dump_16580.rdb /psr/redis_cluster/data/redis_dump_17380.rdb"
  #ssh $host "mv /psr/redis_cluster/data/redis_dump_16581.rdb /psr/redis_cluster/data/redis_dump_17381.rdb"

  #ssh $host "sed -i \"s@6480@6380@\" /psr/redis_cluster/data/redis-cluster-nodes*"
  #ssh $host "sed -i \"s@6481@6381@\" /psr/redis_cluster/data/redis-cluster-nodes*"
  #ssh $host "sed -i \"s@6580@7380@\" /psr/redis_cluster/data/redis-cluster-nodes*"
  #ssh $host "sed -i \"s@6581@7381@\" /psr/redis_cluster/data/redis-cluster-nodes*"

  #ssh $host "cd /psr/redis_cluster/conf; sed -i \"s@^bind 198.218.7.31@bind $host@\" *.conf"
  #ssh $host "rm /psr/redis_cluster/data/redis_dump_16380.rdb /psr/redis_cluster/data/redis_dump_16381.rdb"
  #ssh $host "du -sh /psr/redis_cluster/backup/backup_2018-11-14/*" 

  #scp /psr/redis_cluster/script/include/backup.sh $host:/psr/redis_cluster/script/include/backup.sh
  #ssh $host "cd /psr/redis_cluster/conf; sed -i \"s@^bind 198.218.7.31@bind $host@\" *.conf"
  ssh $host "rm -f /psr/redis_cluster/data/*"
  ssh $host "ls /psr/redis_cluster/data"

  #ssh $host "rm -fr /psr/redis_cluster/script/*"
  #scp -r /psr/redis_cluster/script/* $host:/psr/redis_cluster/script
  #ssh $host "sed -i \"s@^set-max-intset-entries 51@set-max-intset-entries 512@\" /psr/redis_cluster/conf/*.conf"
done
