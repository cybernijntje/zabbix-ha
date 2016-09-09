#!/bin/sh

SOURCE="lb.devops.com"
VM=`cat /etc/hostname`

printf "\n>>>\n>>> WORKING ON: $VM ...\n>>>\n\n>>>\n>>> (STEP 1/3) Configuring system ...\n>>>\n\n\n"
sleep 5
echo 'root:devops' | chpasswd
timedatectl set-timezone Europe/Berlin
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && service sshd restart
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
echo 0 > /sys/fs/selinux/enforce

printf "\n>>>\n>>> (STEP 2/3) Installing Keepalived & HAProxy ...\n>>>\n\n"
sleep 5
yum update
yum -y install keepalived haproxy
cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.orig
cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig

printf "\n>>>\n>>> (STEP 3/3) Configuring Keepalived and HAProxy ...\n>>>\n\n"
sleep 5
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p
cp -f /sources/$SOURCE/keepalived.conf /etc/keepalived/keepalived.conf
cp -f /sources/$SOURCE/haproxy.cfg /etc/haproxy/haproxy.cfg
INTERFACE=`ip a | grep -B2 192.168.144 | head -1 | awk '{print $2}' | cut -d ':' -f1`
sed -i "s/eth1/$INTERFACE/" /etc/keepalived/keepalived.conf
sed -i -e 's/MASTER/SLAVE/' -e 's/200/100/' /etc/keepalived/keepalived.conf
for SERVICE in keepalived haproxy; do systemctl restart $SERVICE; done

printf "\n>>>\n>>> Finished bootstrapping $VM\n"
