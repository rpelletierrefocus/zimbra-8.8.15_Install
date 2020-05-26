cd /opt/zimbra/jetty/webapps/
tar -czvf /srv/zimbra-webapps.tgz zimbra
cd /tmp/
wget -c https://github.com/imanudin11/zimbra-ui/raw/master/zimbra-ui.tgz
tar -zxvf zimbra-ui.tgz
rsync -avP /tmp/zimbra/ /opt/zimbra/jetty/webapps/zimbra/
cd /opt/zimbra/jetty/webapps/zimbra/skins/
rm -rvf harmony/
ln -sf clarity harmony
/opt/zimbra/libexec/zmfixperms -v
su - zimbra -c "zmmailboxdctl restart"
