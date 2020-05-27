# From : https://imanudin.net/2020/01/22/solved-cant-attach-document-files-in-zimbra-html-mode/

mkdir /srv/jetty_base-common-lib
cp /opt/zimbra/jetty_base/common/lib/httpcore-4.4.11.jar /srv/jetty_base-common-lib/
rm /opt/zimbra/jetty_base/common/lib/httpcore-4.4.11.jar

# Use 8.8.12 httpcore
cd /opt/zimbra/jetty_base/common/lib/
wget -c https://raw.githubusercontent.com/imanudin11/lainlain/master/httpcore-4.4.5.jar

# Restart
su - zimbra -c 'zmmailboxdctl restart'
