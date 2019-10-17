#!/bin/bash
source ../config.conf
redis_home=$REDIS_HOME

source $REDIS_HOME/script/include/helps.sh
echo "all_hosts"
all_hosts

echo "get_alive_process"
get_alive_process

echo "get_alive_ip_port"
get_alive_ip_port

echo "get_not_alive_ip_port"
get_not_alive_ip_port

echo "get_latest_config_file"
get_latest_config_file
