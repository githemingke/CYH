#!/bin/bash

# 注:执行前确保网络可用 
# root 目录下必须有 cmake boost mysql 安装包

systemctl stop firewalld 
systemctl disable firewalld 
setenforce 0 
sed -i '/^SELINUX=/ c SELINUX=disabled'  /etc/selinux/config

# aliyun yum源
cd /etc/yum.repos.d/
rm -rf * 
curl -O http://mirrors.aliyun.com/repo/Centos-7.repo
curl -O http://mirrors.aliyun.com/repo/epel-7.repo

# 如果是Redhat系统打开下一行注释，如果是centos则注释下面一行
# sed -i 's/$releasever/7/g' /etc/yum.repos.d/Centos-7.repo
yum clean all && yum repolist 

#配置chronyd时间同步
 rpm -qa | grep chrony
if [ $? = 0 ];then
    echo '已经安装ntp'
else
    yum -y install chrony
    sed -i '/^server 0/ c server ntp1.aliyun.com iburst' /etc/chrony.conf 
    sed -i 's/^server 3/#server/g ' /etc/chrony.conf
    sed -i 's/^server 2/#server/g ' /etc/chrony.conf
    sed -i 's/^server 1/#server/g ' /etc/chrony.conf
    systemctl restart chronyd
fi
#卸载mariadb相关组件
rpm -qa | grep mariadb-libs | xargs rpm -e --nodeps &> /dev/null

if [ -d  /data ];then
    rm -rf /data
else 
    echo '没有/data/目录，帮您创建'
fi

if [ -d  /usr/local/boost ];then
    rm -rf /usr/local/boost
else 
    echo '没有/usr/local/boost/目录，帮您创建'
fi

mkdir -p /data/mysql/installdir
mkdir -p /data/mysql/datadir/3306/data
mkdir -p /data/mysql/logdir/3306/{bin_log,general_log,error_log,query_log,relay_log}
mkdir -p /data/mysql/tmpdir 
mkdir -p /data/mysql/src
mkdir -p /usr/local/boost

# 创建MySQL用户和组
grep '/sbin/nologin' /etc/shells 
if [ $? = 0 ];then
    groupadd -r mysql && useradd -r -g mysql -s /sbin/nologin mysql &>/dev/null
else 
    echo '/sbin/nologin' >> /etc/shells
    groupadd -r mysql && useradd -r -g mysql -s /sbin/nologin mysql &>/dev/null
fi

# 安装依赖包
yum -y install ncurses ncurses-devel openssl-devel bison gcc gcc-c++ 

#将root目录下的包拷贝到安装目录,确保/root下有cmake、mysql、boost包
# 安装cmake
cd /root
cp -r  *.tar.gz  /data/mysql/src/
cd  /data/mysql/src/
tar -xf cmake-3.11.1.tar.gz 
cd cmake-3.11.1 
./bootstrap
gmake && gmake install 

chown -R mysql:mysql /data/

# 安装boost
cd /data/mysql/src/
tar -xf boost_1_59_0.tar.gz -C /usr/local/boost/
\cp -rf /root/my.cnf /etc

# 编译MySQL
cd /data/mysql/src/ 
tar -xf mysql-5.7.18.tar.gz 
cd mysql-5.7.18
#cmake . -DCMAKE_INSTALL_PREFIX=/data/mysql/installdir -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DENABLED_LOCAL_INFILE=ON -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITHOUT_EXAMPLE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_PERFSCHEMA_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/usr/local/boost -DSYSCONFDIR=/data/mysql/datadir/3306/data -DMYSQL_UNIX_ADDR=/data/mysql/datadir/3306/data/mysql.sock
cmake . -DCMAKE_INSTALL_PREFIX=/data/mysql/installdir \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DENABLED_LOCAL_INFILE=ON \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITHOUT_EXAMPLE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_PERFSCHEMA_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DEXTRA_CHARSETS=all \
-DWITH_BOOST=/usr/local/boost \
-DMYSQL_DATADIR=/data/mysql/datadir/3306/data \
-DSYSCONFDIR=/etc \
-DMYSQL_UNIX_ADDR=/data/mysql/datadir/3306/data/mysql.sock
make -j `grep processor /proc/cpuinfo | wc -l`  && make install 
##注:根据cpu核数选择合适的数字 make -j ?

echo "export PATH=$PATH:/data/mysql/installdir/bin/" >> /etc/profile
source /etc/profile
chown -R mysql:mysql /data/

##初始化mysql
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

# 安装结束后，手动执行 source /etc/profile
# 如果初始化失败，将my.cnf 重新复制到/etc下，再执行初始化脚本



