#!/bin/bash
source ./config.conf

if [ "$1" == "start" ]; then
  bash $REDIS_HOME/script/include/start.sh $2
elif [ "$1" == "stop" ]; then
  bash $REDIS_HOME/script/include/stop.sh $2 $3
elif [ "$1" == "status" ]; then
  bash $REDIS_HOME/script/include/status.sh
elif [ "$1" == "backup" ]; then
  bash $REDIS_HOME/script/include/backup-all.sh
elif [ "$1" == "restore" ]; then
  bash $REDIS_HOME/script/include/restore.sh $2
else
  cat << HELP
使用说明：
cluster.sh start (master|slave)
# 启动master或者slave

cluster.sh stop (master|slave) stop_type
# 停止master或者slave，stop_type: '1': SHUTDOWN SAVE, '2': SHUTDOWN, '3': kill 

cluster.sh status
# 查看集群的进程状态

cluster.sh backup
# 备份当前集群数据

cluster.sh restore backup_dir
# 恢复集群，backup_dir: 备份文件所在位置

HELP
fi

