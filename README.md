# 添加脚本
git clone ../redis-cluster-script.git script

# 修改配置
1. 修改配置文件config.conf 
2. 修改backup.sh 
```
redis_home=${1:-"/home/liuhq/bin/redis_cluster"}
```


# 拷贝backup.sh到集群所有机器上,增加crontab
可参考脚本
```
cat > add_crontab.sh <<BG
redis_home="/home/liuhq/bin/redis_cluster"
all_servers=`cat $redis_home/script/hosts.conf`

for host in $all_servers; do
  echo "server on $host"
  ssh liuhq@$host << eeooff
croncmd="\$redis_home/script/include/backup.sh >> \$redis_home/log/backup.log 2>&1"
cronjob="0 0 * * * \$croncmd"
# add
( crontab -l | grep -v -F "\$croncmd" ; echo "\$cronjob" ) | crontab -

# delete
#( crontab -l | grep -v -F "\$croncmd") | crontab -
crontab -l
eeooff
done
BG
```
