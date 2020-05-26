source .env

for i in $(echo ${ADMINS} | sed "s/,/ /g")
do
    # call your procedure/other scripts here below
    echo "$i"
done
