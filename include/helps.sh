#!/bin/bashalive_one=$(get_alive_process | head -n 1 | awk '{print $3}')

function get_cluster_nodes(){
  alive_one=$(get_alive_process | head -n 1 | awk '{print $3}')

  $redis_home/bin/redis-cli -u redis://$alive_one -c cluster nodes
}

function get_cluster_status(){
  alive_one=$(get_alive_process | head -n 1 | awk '{print $3}')

  $redis_home/bin/redis-cli -u redis://$alive_one -c cluster info | grep cluster_state
}

function all_host_ports() {
  default_ports=$DEFAULT_MASTER_PORT" "$DEFAULT_SLAVE_PORT
  if [ "$1" == "master" ]; then
    default_ports=$DEFAULT_MASTER_PORT
  fi

  for host in $CLUSTER_HOSTS; do
    for port in $default_ports; do
      echo "${host}:${port}"
    done
  done
}

function get_alive_process(){
 ports=$DEFAULT_MASTER_PORT" "$DEFAULT_SLAVE_PORT
 ports_reg=${ports// /\\|}

 for host in $CLUSTER_HOSTS; do
   ssh $host "pgrep redis-server -a| grep '$ports_reg'"
 done
}

function get_alive_ip_port() {
  get_alive_process | awk '{print $3}'
}

function get_not_alive_ip_port() {
  alive_host_port=$(echo $(get_alive_ip_port))
  alive_host_port_reg=${alive_host_port// /\\|}

  all_host_ports | grep -v "$alive_host_port_reg"
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
  for host in $CLUSTER_HOSTS; do
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
