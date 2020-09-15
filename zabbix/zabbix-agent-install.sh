#!/bin/bash
# system requirements centos-7

systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
timedatectl set-timezone Asia/Shanghai

yum clean all
num = `yum repolist | grep repolist |awk -F : '{print $2}' |sed  -n 's/,//p'`
if test $num -eq 0; then 
    mkdir -p  /etc/yum.repos.d/backup
    mv  /etc/yum.repos.d/*.repo  /etc/yum.repos.d/backup
    cd /etc/yum.repos.d/
    curl -O http://mirrors.aliyun.com/repo/Centos-7.repo
    curl -O http://mirrors.aliyun.com/repo/epel-7.repo
    yum makecache 
    yum -y install gcc pcre-devel ntpdate git
    ntpdate ntp1.aliyun.com 
else
    yum -y install gcc pcre-devel ntpdate git 
    ntpdate ntp1.aliyun.com 
fi 

cd /opt 
git clone -b zabbix  http://hmk:admin123456@10.60.11.110/CYH/cyh-project.git
cd /opt/cyh-project/zabbix

tar -xf zabbix-4.2.6.tar.gz 
if [ -d zabbix-4.2.6 ];then
    cd zabbix-4.2.6
    grep "/sbin/nologin" /etc/shells
    if [ $? -eq 0 ]; then 
        useradd -s /sbin/nologin zabbix
        ./configure --prefix=/usr/local/zabbix --enable-agent && make install && cd /usr/local/zabbix/etc 
    else
        echo "/sbin/nologin" >> /etc/shells
        useradd -s /sbin/nologin zabbix
        ./configure --prefix=/usr/local/zabbix --enable-agent && make install && cd /usr/local/zabbix/etc 
        
    fi
else
    exit 3
fi 

cd /usr/local/zabbix/etc/
cp zabbix_agentd.conf zabbix_agentd.conf.bak
sed -i  '/^Server=/c Server=10.60.11.111' zabbix_agentd.conf
# sed -i 's/^ServerActive/#ServerActive/' zabbix_agentd.conf
sed -i '/^ServerActive=/c ServerActive=10.60.11.111' zabbix_agentd.conf
# sed -i "/^Hostname/c Hostname=`\hostname`" zabbix_agentd.conf 
sed -i "/^Hostname/c #Hostname=`\hostname`" zabbix_agentd.conf 
sed -i "/^# HostnameItem=/c HostnameItem=system.hostname" zabbix_agentd.conf
sed -i "/^# HostMetadataItem=/c HostMetadataItem=system.uname" zabbix_agentd.conf
sed -i "/^# Enable/c EnableRemoteCommands=1" zabbix_agentd.conf
sed -i "/^# Unsafe/c UnsafeUserParameters=1" zabbix_agentd.conf
sed -i "/^# Include=\/usr\/local\/etc\/zabbix_agentd.conf.d\/\*.conf/c Include=\/usr\/local\/zabbix\/etc\/zabbix_agentd.conf.d\/\*.conf" zabbix_agentd.conf

/usr/local/zabbix/sbin/zabbix_agentd
ps aux |grep zabbix
if test $? -eq 0;then
    rm -rf /opt/cyh-project
else 
    exit 3 
fi 
# zabbix-server 端已启用自动注册，无需web页面添加主机
