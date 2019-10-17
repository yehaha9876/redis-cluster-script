# 添加脚本
git clone ../redis-cluster-script.git script

# 修改配置
1. 修改配置文件config.conf 
2. 修改backup.sh 
```
redis_home=${1:-"/home/liuhq/bin/redis_cluster"}
```

# 拷贝backup.sh到集群所有机器上

# 使用add_crontab.sh 增加crontab
