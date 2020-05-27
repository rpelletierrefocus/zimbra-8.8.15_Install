hostnamectl set-hostname mail
cd ..
rm -Rf zimbra-automated-installation
git clone https://github.com/rpelletierrefocus/zimbra-automated-installation.git
cd zimbra-automated-installation
chmod +x ZimbraEasyInstall-8.8.15
./ZimbraEasyInstall-8.8.15 flmaine.com 10.100.113.34 NEWsysadm1n
