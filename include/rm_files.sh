#!/bin/sh
source ../config.conf
source $REDIS_HOME/script/include/helps.sh

for host in $(all_hosts); do 
  echo "server on $host"
  #scp -r $REDIS_HOME/* $host:$REDIS_HOME
  #ssh $host "cd $REDIS_HOME/conf; sed -i \"s@^maxmemory 6gb@maxmemory 7gb@\" *.conf"
done
