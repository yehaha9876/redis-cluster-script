# 修改配置
1. 修改server的host地址
host.conf
```
192.168.3.1
192.168.3.2
```
2. 项目根目录，这个需要全局替换
例如:
```
sed -i 's@/trs6/redis_cluster@/jboss/redis/redis_cluster@' *.sh
```
注意: include 目录也要替换


3. 增加crontab
参考add_crontab.sh
