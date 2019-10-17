#!/bin/bash

function get_cluster_nodes(){
  alive_one=$(get_alive_ip_port_one)

  $redis_home/bin/redis-cli -u redis://$alive_one -c cluster nodes
}

function get_cluster_status(){
  alive_one=$(get_alive_ip_port_one)

  $redis_home/bin/redis-cli -u redis://$alive_one -c cluster info | grep cluster_state
}

function all_host_ports() {
  host_ports="${CLUSTER_MASTER} ${CLUSTER_SLAVE}"
  if [ "$1" == "master" ]; then
    host_prots=$CLUSTER_MASTER
  fi
  for host_port in $host_ports; do
    echo $host_port
  done
}

function all_hosts(){
  all_host_ports | awk -F ":" '{print $1}' | sort | uniq
}

function get_alive_process(){
  host_ports=$(all_host_ports)
  host_ports_reg=${host_ports// /\\|}
  cluster_hosts=$(all_hosts)

  for host in $cluster_hosts; do
    echo "===== $host ==============="
    ssh $host "ps -ef | grep redis-server" | grep "$host_ports_reg"
  done
}

function get_alive_ip_port() {
  get_alive_process | grep "redis-server" | awk '{print $9}'
}

function get_alive_ip_port_one() {
  get_alive_ip_port | head -n 1
}

function get_not_alive_ip_port() {
  alive_host_port=$(echo $(get_alive_ip_port))
  alive_host_port_reg=${alive_host_port// /\\|}

  if [ "$alive_host_port_reg" == "" ]; then
    all_host_ports
  else
    all_host_ports | grep -v "$alive_host_port_reg"
  fi
}

function get_cluster_nodes_from_config(){
  config=$(get_latest_config_file)

  if [ "$config" = "" ]; then 
    exit 1
  fi

  host=${config%:*}
  file=${config#*:}
  ssh $host "cat $file | grep @"
}

function get_latest_config_file() {
  cluster_hosts=$(all_hosts)
  for host in $cluster_hosts; do
    ssh $host "printf '$host:'; grep currentEpoch $REDIS_HOME/data/redis-cluster-nodes-*.conf | sort -k 3 | tail -n 1"
  done | sort -k 3 | tail -n 1 | awk -F ":" '{print $1":"$2}'
}

function wait_cluster_ready() {
  try=720
  while [ $try -gt 0 ] ; do
    cluster_status=$(get_cluster_status)

    if [[ "$cluster_status" == "cluster_state:ok*" ]] ; then
      return 0
    fi

    try=$((try - 1))
    echo "[$port] redis maybe busy, waiting and retry in 5s..."
    sleep 5
  done
  return 1
}
