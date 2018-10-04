#!/bin/bash
echo Please enter the name of the file to be tranferred \(full path if file is not in current folder\):
read file_name
echo $file_name will be copied to _____________________________________
scp $file_name ________________________________________
#echo Please enter the name of the database backup file in the server \(full path if file is not in /home/ubuntu\):
db_backup_file=${file_name##*/}
date_string=${db_backup_file##*_}
echo Please enter the name of PostgreSQL container where the backup should be copied:
read psql_container
tmp_path=":/tmp"
ssh ubuntu@mortgagekart.technology <<EOF1
echo $db_backup_file will be copied to $psql_container$tmp_path
docker cp $db_backup_file $psql_container$tmp_path
docker exec -i $psql_container /bin/bash <<EOF2
echo creating directory with name $date_string
mkdir -p $date_string
chmod 777 -R $date_string
su postgres
echo Logging into DB now
psql postgres <<EOF3
REVOKE CONNECT ON DATABASE harmony_products FROM public;
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'harmony_products';
drop database harmony_products;
create database harmony_products;
EOF3
cd /tmp
echo restoring Database dump
pg_restore -U postgres -d harmony_products -1 $db_backup_file
echo restoration complete
cd ..
echo copying backup file to $date_string directory
cp /tmp/$db_backup_file /$date_string/
echo copying complete
exit
EOF2
exit
EOF1
