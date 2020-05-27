#!/usr/bin/python

# coding=UTF-8

'''

The script will compare the user list from an AD group with the members from a distribution list

If the user is on AD and not on the list, it will add it to the list

If the user is on the list but not on AD, it will remove it from the list

Tested on Zimbra FOSS 8.0.4

'''

# search domain
domain = 'domain.com'

# users domain on zimbra
emaildomain='domain.com'

# path to zmprov
pathtozmprov="/opt/zimbra/bin/zmprov"


## Set these variables
AD_SERVERS = [ '10.100.61.60']
AD_USER_BASEDN = "OU=Domain Users,DC=domain,DC=com"
AD_GROUP_BASEDN = "OU=Distribution Lists,OU=Domain Groups,DC=domain,DC=com"
AD_USER_FILTER = '(&(objectClass=USER)(sAMAccountName={username}))'
AD_USER_FILTER2 = '(&(objectClass=USER)(dn={userdn}))'
AD_GROUP_FILTER = '(&(objectClass=GROUP)(cn={group_name}))'
AD_BIND_USER = 'admin@domain.com'
AD_BIND_PWD = 'P@ssw0rd'

#--------------------------------------------------------------------------------------------------

import ldap, string, os, sys, subprocess

#Function to assure that all email domains are consistent
def fix_email(email):
    sep = '@'
    email = email.rstrip('\n')
    email = email.split(sep, 1)[0]
    email = email + '@' + emaildomain
    return email

# ldap connection
def ad_auth(username=AD_BIND_USER, password=AD_BIND_PWD, address=AD_SERVERS[0]):
        conn = ldap.initialize('ldap://' + address)
        conn.protocol_version = 3
        conn.set_option(ldap.OPT_REFERRALS, 0)

        result = True

        try:
                conn.simple_bind_s(username, password)
                print "Succesfully authenticated"
        except ldap.INVALID_CREDENTIALS:
                return "Invalid credentials", False
        except ldap.SERVER_DOWN:
                return "Server down", False
        except ldap.LDAPError, e:
                if type(e.message) == dict and e.message.has_key('desc'):
                        return "Other LDAP error: " + e.message['desc'], False
                else:
                        return "Other LDAP error: " + e, False

        return conn, result

def get_dn_by_username(username, ad_conn, basedn=AD_USER_BASEDN):
        return_dn = ''
        ad_filter = AD_USER_FILTER.replace('{username}', username)
        results = ad_conn.search_s(basedn, ldap.SCOPE_SUBTREE, ad_filter)
        if results:
                for dn, others in results:
                        return_dn = dn
        return return_dn

#
# query only enabled users with the following filter
# (!(userAccountControl:1.2.840.113556.1.4.803:=2))
#
def get_email_by_dn(dn, ad_conn):
        email = ''
        result = ad_conn.search_s(dn, ldap.SCOPE_BASE, \
                '(&(objectCategory=person)(objectClass=user)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))')
        if result:
                for dn, attrb in result:
                        if 'mail' in attrb and attrb['mail']:
                                email = attrb['mail'][0].lower()
                                break
        return email

def get_group_members(group_name, ad_conn, basedn=AD_GROUP_BASEDN):
        members = []
        ad_filter = AD_GROUP_FILTER.replace('{group_name}', group_name)
        result = ad_conn.search_s(basedn, ldap.SCOPE_SUBTREE, ad_filter)
        if result:
                if len(result[0]) >= 2 and 'member' in result[0][1]:
                        members_tmp = result[0][1]['member']
                        for m in members_tmp:
                                email = get_email_by_dn(m, ad_conn)
                                if email:
                                        members.append(fix_email(email))
        return members



if __name__ == "__main__":
  ad_conn, result = ad_auth()
  groups = []
  if result:
    for dn, entry in ad_conn.search_s(AD_GROUP_BASEDN, ldap.SCOPE_SUBTREE, '(&(objectClass=group))'):
      groups.append(entry['cn'][0])

for group in groups:

  group_name = group

  group_members = get_group_members(group_name, ad_conn)

  if os.system(pathtozmprov +' gdl %s@%s >/dev/null 2>&1' % (group,emaildomain)) != 0:
    print 'Adding Distribution List: ' + group + '@' + emaildomain
    #os.system(pathtozmprov +' cdl %s@%s >/dev/null 2>&1' % (group,emaildomain))
    subprocess.check_output(pathtozmprov +' cdl ' + group + '@' + emaildomain, shell=True)
  else:
    print 'Group ' + group + ' Exists'

  f = os.popen(pathtozmprov +' gdlm '+ group + '@' + emaildomain +' | egrep -v "^$" | grep -v members | grep -v "#"')

  member_list_tmp = []

  member_list_tmp = f.readlines()

  member_list = []

  for n in member_list_tmp:
    member_list.append(fix_email(n))

  res2=[]

  print member_list

  for m in group_members:
    print m

    # WORKAROUND: Add \n because member_list has this added to each user for some reason
    if m not in member_list:

      print 'Adding '+m+ ' to '+ group+'@'+emaildomain

      os.system(pathtozmprov +' adlm %s@%s %s >/dev/null 2>&1' % (group,emaildomain,m))

    res2.append(m)

  print res2

  for value in member_list:

    accountname = fix_email(value)

    print accountname

    if accountname not in res2:

      print 'Removing '+accountname+ ' from '+ group +'@'+emaildomain

      os.system(pathtozmprov +' rdlm %s@%s %s' % (group,emaildomain,accountname))


