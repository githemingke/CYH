#!/bin/bash
# 脚本执行完后在浏览器输入ip/index.php设置向导即可

systemctl stop firewalld
systemctl disable firewalld
setenforce 0 
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
timedatectl set-timezone Asia/Shanghai

cd /etc/yum.repos.d/
rm -rf *
curl -O http://mirrors.aliyun.com/repo/Centos-7.repo
curl -O http://mirrors.aliyun.com/repo/epel-7.repo
yum clean all && yum repolist
yum -y install gcc pcre-devel  openssl-devel php php-mysql php-fpm mariadb mariadb-devel mariadb-server 
yum -y install net-snmp-devel curl-devel libvent-devel net-snmp-devel libxml2-devel unixODBC libssh2-deve OpenIPMI OpenIPMI-devel unixODBC-devel ncurses-devel glibc.i686 ntpdate

ntpdate ntp1.aliyun.com 

cd /root/zabbix/
tar -xf nginx-1.12.2.tar.gz 
cd nginx1.12.2
useradd -s /sbin/nologin nginx
./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module
make -j && make install 

scp /root/zabbix/nginx.conf /usr/local/nginx/conf/nginx.conf

/usr/local/nginx/sbin/nginx
systemctl start  mariadb php-fpm

cd /root/zabbix
tar -zxvf zabbix-4.2.6.tar.gz
cd zabbix-4.2.6
useradd zabbix
./configure --prefix=/usr/local/zabbix --enable-server --enable-agent --with-mysql --with-net-snmp --with-libcurl --with-libxml2 --with-unixodbc --with-ssh2 --with-openipmi --enable-ipv6 --enable-java --with-openssl --with-ssh2 --with-iconv --with-iconv-include --with-iconv-lib --with-libpcre --with-libpcre-include --with-libpcre-lib --with-libevent --with-libevent-include --with-zlib --with-zlib-include --with-zlib-lib --with-libpthread --with-libpthread-include --with-libpthread-lib --with-libevent-lib --with-ldap --with-proxy
make -j 4 && make install

mysql -e "create database zabbix character set utf8;"
mysql -e "grant all on zabbix.* to zabbix@'localhost' identified by 'zabbix';"
cd /root/zabbix/zabbix-4.2.6/database/mysql
mysql -uzabbix -pzabbix zabbix < schema.sql
mysql -uzabbix -pzabbix zabbix < images.sql
mysql -uzabbix -pzabbix zabbix < data.sql

cd /root/zabbix/zabbix-4.2.6/frontends/php/
cp -r * /usr/local/nginx/html/
chmod -R 777 /usr/local/nginx/html/*
scp /root/zabbix/zabbix_agentd.conf /usr/local/zabbix/etc/zabbix_agentd.conf
scp /root/zabbix/zabbix_server.conf /usr/local/zabbix/etc/zabbix_server.conf
/usr/local/zabbix/sbin/zabbix_server 
/usr/local/zabbix/sbin/zabbix_agentd


yum -y install  php-gd php-xml  php-bcmath  php-mbstring php-ldap
scp /root/zabbix/php.ini /etc/
systemctl restart php-fpm

