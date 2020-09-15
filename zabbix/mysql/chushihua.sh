#!/bin/bash
rm -rf /data/mysql/datadir
rm -rf /data/mysql/logdir
mkdir -p /data/mysql/datadir/3306/data
mkdir -p /data/mysql/logdir/3306/{bin_log,general_log,error_log,query_log,relay_log}
chown -R mysql:mysql /data/
#
cd /data/mysql/installdir/bin
./mysqld --initialize --user=mysql --basedir=/data/mysql/installdir --datadir=/data/mysql/datadir/3306/data --tmpdir=/data/mysql/tmpdir --explicit_defaults_for_timestamp
sleep 5
./mysql_ssl_rsa_setup --datadir=/data/mysql/datadir/3306/data
cp /data/mysql/installdir/support-files/mysql.server  /etc/init.d/mysqld
chown -R mysql:mysql /data/*
/etc/init.d/mysqld start
if [ $? = 0 ];then
    password=`grep password /data/mysql/logdir/3306/error_log/mysql3.err | sed -n 1p | awk '{print $NF}'`
    echo -e mysql password is "\033[1;5;31m$password\033[0m"
    echo "please change"
else 
    echo error
fi  

