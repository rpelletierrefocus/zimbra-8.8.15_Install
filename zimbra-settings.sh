# Should run this only after domain users have been imported
source .env

for i in $(echo ${ADMINS} | sed "s/,/ /g")
do
   
    echo "Adding as admin $i"
    zmprov ma $i@{$DOMAIN} zimbraIsAdminAccount TRUE
done

zmprov sp admin@flmaine.com ${ADMINPASS}


wget https://github.com/rpelletierrefocus/zimbra-rocket/blob/master/extension/rocket.jar
cp extension.jar /opt/zimbra/lib/ext/rocket/
 su - zimbra -c '/opt/zimbra/bin/zmmailboxdctl restart'


/opt/zimbra/libexec/zmfixperms



apt-get -y install zabbix-agent









## Install zmbackup
cd /tmp
apt-get install parallel wget httpie sqlite3 -y
git clone -b 1.2-version https://github.com/lucascbeyeler/zmbackup.git
cd zmbackup
./install.sh

## Install filebeat


# Install telegraf








#### fstab
10.100.61.20:/volume1/backup1/docker-containers /mnt/containers  nfs      defaults    0       0
10.100.61.21:/volume1/mailstore  /backup/mailbox_backup  nfs      defaults    0       0
/dev/sdb1    /opt/zimbra/opt/zimbra/store  ext4  defaults,auto,_netdev    0    0
/dev/sdc1    /mailstore  ext4  defaults,auto,_netdev    0    0



