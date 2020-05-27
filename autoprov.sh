source .env

cat <<EOF >/tmp/autoprov.txt
md ${DOMAIN} zimbraAutoProvAccountNameMap "samAccountName"
md ${DOMAIN} zimbraAutoProvAttrMap description=description
md ${DOMAIN} zimbraAutoProvAttrMap displayName=displayName
md ${DOMAIN} zimbraAutoProvAttrMap givenName=givenName
md ${DOMAIN} zimbraAutoProvAttrMap cn=cn
md ${DOMAIN} zimbraAutoProvAttrMap sn=sn
md ${DOMAIN} zimbraAutoProvAuthMech LDAP
md ${DOMAIN} zimbraAutoProvBatchSize 40
md ${DOMAIN} zimbraAutoProvLdapAdminBindDn ${BINDDN}
md ${DOMAIN} zimbraAutoProvLdapAdminBindPassword ${BINDPW}
md ${DOMAIN} zimbraAutoProvLdapBindDn ${BINDDN}
md ${DOMAIN} zimbraAutoProvLdapSearchBase ${LDAPSEARCHBASE}
md ${DOMAIN} zimbraAutoProvLdapSearchFilter "(cn=%u)"
md ${DOMAIN} zimbraAutoProvLdapURL "ldap://${LDAPSERVER}:389"
md ${DOMAIN} zimbraAutoProvMode EAGER
md ${DOMAIN} zimbraAutoProvNotificationBody "Your account has been auto provisioned. Your email address is ${ACCOUNT_ADDRESS}."
md ${DOMAIN} zimbraAutoProvNotificationFromAddress no-reply@${DOMAIN}
md ${DOMAIN} zimbraAutoProvNotificationSubject "New account auto provisioned"
ms ${HOSTNAME}.${DOMAIN} zimbraAutoProvPollingInterval "1m"
ms ${HOSTNAME}.${DOMAIN} +zimbraAutoProvScheduledDomains "${DOMAIN}"
EOF

zmprov < /tmp/autoprov.txt


#https://wiki.zimbra.com/wiki/How_to_configure_auto-provisioning_with_AD
