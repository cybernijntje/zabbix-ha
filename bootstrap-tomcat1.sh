#!/bin/sh

SOURCE="tomcat.devops.com"
VM=`cat /etc/hostname`

printf "\n>>>\n>>> WORKING ON: $VM ...\n>>>\n\n>>>\n>>> (STEP 1/4) Configuring system ...\n>>>\n\n\n"
sleep 5
echo 'root:devops' | chpasswd
timedatectl set-timezone Europe/Berlin
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && service sshd restart
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
echo 0 > /sys/fs/selinux/enforce

printf "\n>>>\n>>> (STEP 2/4) Installing OpenJDK ...\n>>>\n\n"
sleep 5
yum update
yum -y install java-1.7.0-openjdk-devel

printf "\n>>>\n>>> (STEP 3/4) Installing Apache Tomcat ...\n>>>\n\n"
sleep 5
groupadd tomcat
useradd -M -s /bin/nologin -g tomcat -d /opt/tomcat tomcat
mkdir /opt/tomcat
tar xvf /sources/$SOURCE/apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1
cp /sources/$SOURCE/setenv.sh /opt/tomcat/bin
/opt/tomcat/bin/startup.sh

printf "\n>>>\n>>> (STEP 4/4) Installing Zabbix agent ...\n>>>\n\n"
rpm -Uvh http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
yum install -y zabbix zabbix-agent
cp -f /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.orig
sed -i -e 's/Server=127.0.0.1/Server=192.168.144.15/' \
-e 's/ServerActive=127.0.0.1/ServerActive=192.168.144.15/' \
-e "s/Hostname=Zabbix server/Hostname=`cat /etc/hostname`/" \
-e "s/# HostMetadata=/HostMetadata=`cat /etc/hostname | cut -d "." -f1`/" /etc/zabbix/zabbix_agentd.conf
systemctl start zabbix-agent && systemctl enable zabbix-agent

printf "\n>>>\n>>> Finished bootstrapping $VM\n>>>\n\n>>> Tomcat is reachable via:\n>>> http://$VM:8080\n"
