# Should run this only after domain users have been imported
source .env

for i in $(echo ${ADMINS} | sed "s/,/ /g")
do
    echo "Adding as admin $i"
    zmprov ma $i@{$DOMAIN} zimbraIsAdminAccount TRUE
done

## Update admin password
zmprov sp admin@flmaine.com ${ADMINPASS}


## Add Rocket Chat zimlet
su - zimbra -c 'zmprov fc -a zimlet'
cd /tmp
wget wget https://github.com/rpelletierrefocus/zimbra-rocket/blob/master/releases/rocket.jar
wget wget https://github.com/rpelletierrefocus/zimbra-rocket/blob/master/releases/com_zimbra_rocket.zip
su - zimbra -c 'zmzimletctl deploy /tmp/com_zimbra_rocket.zip'
su - zimbra -c 'zmcontrol restart'
su - zimbra -c 'zmzimletctl getConfigTemplate /tmp/com_zimbra_rocket.zip > /tmp/config_template.xml.tmp'
nano /tmp/config_template.xml.tmp
su - zimbra -c 'zmzimletctl configure /tmp/config_template.xml.tmp'

su - zimbra -c 'zmprov fc -a zimlet'

# Copy rocket.jar
mkdir /opt/zimbra/lib/ext/rocket/

cp rocket.jar /opt/zimbra/lib/ext/rocket/extension.jar
touch /opt/zimbra/lib/ext/rocket/config.properties
cat <<EOF >/opt/zimbra/lib/ext/rocket/config.properties
adminuser=adminUsername
adminpassword=adminPassword
rocketurl=https://rocket.example.org
loginurl=https://mail.example.org
domaininusername=true
EOF
nano /opt/zimbra/lib/ext/rocket/config.properties

# Debug
wget https://github.com/Zimbra-Community/zimbra-rocket/raw/master/rocket-test/out/artifacts/rocket_test_jar/rocket-test.jar -O /tmp/rocket-test.jar
su - zimbra -c '/opt/zimbra/common/lib/jvm/java/bin/java -jar /tmp/rocket-test.jar'



su - zimbra -c '/opt/zimbra/bin/zmmailboxdctl restart'

## Fix Permissions
/opt/zimbra/libexec/zmfixperms


## Add logos
zmprov md flmaine.com zimbraSkinLogoURL https://www.freightlinerofmaine.com
zmprov md flmaine.com zimbraSkinLogoLoginBanner /logos/LoginBanner_white.png
zmmailboxdctl restart


## Install zabbix-agent
cd /tmp
wget https://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-3%2Bxenial_all.deb
dpkg -i zabbix-release_4.0-2+bionic_all.deb
sudo apt update
apt-get -y install zabbix-agent


## Install zmbackup
cd /tmp
apt-get install parallel wget httpie sqlite3 git -y
git clone -b 1.2-version https://github.com/lucascbeyeler/zmbackup.git
cd zmbackup
./install.sh

## Install filebeat
apt install filebeat

# Install telegraf
apt install telegraf

#### fstab
10.100.61.20:/volume1/backup1/docker-containers /mnt/containers  nfs      defaults    0       0
10.100.61.21:/volume1/mailstore  /backup/mailbox_backup  nfs      defaults    0       0
/dev/sdb1    /opt/zimbra/opt/zimbra/store  ext4  defaults,auto,_netdev    0    0
/dev/sdc1    /mailstore  ext4  defaults,auto,_netdev    0    0

## Add group import script
apt install python python-pip python-ldap -y
(crontab -l 2>/dev/null; echo "*/5 * * * * /path/to/job -with args") | crontab -



