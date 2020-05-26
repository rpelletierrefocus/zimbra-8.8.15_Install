# Should run this only after domain users have been imported
source .env

for i in $(echo ${ADMINS} | sed "s/,/ /g")
do
   
    echo "Adding as admin $i"
    zmprov ma $i@{$DOMAIN} zimbraIsAdminAccount TRUE
done

zmprov sp admin@flmaine.com ${ADMINPASS}
