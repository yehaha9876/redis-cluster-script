source ./config.conf
source $REDIS_HOME/script/include/helps.sh

croncmd="$REDIS_HOME/script/include/backup.sh >> $REDIS_HOME/log/backup.log 2>&1"
cronjob="0 0 * * * $croncmd"
echo $cronjob

for host in $(all_hosts); do
  echo "server on $host"
  ssh $host << eeooff
# add
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -

# delete
#( crontab -l | grep -v -F "$croncmd") | crontab -
crontab -l
eeooff
done
