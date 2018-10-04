#!/bin/bash
echo Do you want to upload product xml?
echo Enter y for yes, n for no:
read xml_upload_ind
if [ "$xml_upload_ind" "==" "y" ]; then
echo Please enter the name of the xml file to be tranferred \(full path if file is not in current folder\):
read xml_file_name
echo $xml_file_name will be copied to _______________________________
scp $xml_file_name _________________________________________
#echo Please enter the name of the database backup file in the server \(full path if file is not in /home/ubuntu\):
xml_file=${xml_file_name##*/}
echo Please enter the name of PostgreSQL container where the backup should be copied:
read psql_container
tmp_path=":/tmp"
echo Please enter the database user id:
read prod_uid
echo Please enter the datbase password:
read prod_pwd
echo Please enter the name of PostgreSQL container where the database is located:
read psql_container
fi
ssh ubuntu@mortgagekart.technology <<EOF1
if [ "$xml_upload_ind" "==" "y" ]; then
echo copying pyhton package to container
docker cp $xml_file $psql_container$tmp_path
fi
docker exec -i $psql_container /bin/bash <<EOF2
su postgres
if [ "$xml_upload_ind" = "y" ]; then
python3 <<EOF3
import BRV.entrypoint as entrp
entrp.entrypoint("$prod_uid", "$prod_pwd", "/tmp/$xml_file")
exit()
EOF3
fi
echo uploading xml file complete
exit
EOF2
exit
EOF1
