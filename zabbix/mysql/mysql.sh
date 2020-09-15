#!/bin/bash
rpm -qa | grep mariadb-libs | xargs rpm -e --nodeps &> /dev/null
rpm -qa|grep mysql | xargs rpm -e --nodeps
rm -rf /usr/local/mysql
\cp -rf /root/my.cnf /etc
userdel mysql
groupadd mysql
useradd -r -g mysql -s /sbin/nologin mysql
tar -xf /usr/local/src/mysql-5.7.20-linux-glibc2.12-x86_64.tar.gz -C /usr/local/
cd /usr/local
mv mysql-5.7.20-linux-glibc2.12-x86_64 mysql
cd mysql
mkdir mysql-files
mkdir log
mkdir data
chmod 750 mysql-files
chown -R mysql:mysql /usr/local/mysql
bin/mysqld --initialize-insecure --user=mysql  --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
bin/mysql_ssl_rsa_setup --datadir=/usr/local/mysql/data
chown -R mysql:mysql /usr/local/mysql/*
\cp -rf /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
service mysqld start
echo "export PATH=$PATH:/usr/local/mysql/bin" >> /etc/profile

