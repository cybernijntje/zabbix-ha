#!/bin/sh

SOURCE="grafana.devops.com"
VM=`cat /etc/hostname`

printf "\n>>>\n>>> WORKING ON: $VM ...\n>>>\n\n>>>\n>>> (STEP 1/4) Configuring system ...\n>>>\n\n\n"
sleep 5
echo 'root:devops' | chpasswd
timedatectl set-timezone Europe/Berlin
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && service sshd restart
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
echo 0 > /sys/fs/selinux/enforce

printf "\n>>>\n>>> (STEP 2/4) Installing Grafana ...\n>>>\n\n"
sleep 5
cp /sources/$SOURCE/grafana.repo /etc/yum.repos.d/
yum update
yum -y install grafana
grafana-cli plugins install alexanderzobnin-zabbix-app
systemctl daemon-reload && systemctl start grafana-server && systemctl enable grafana-server

printf "\n>>>\n>>> Finished bootstrapping $VM\n>>>\n\n>>> Grafana is reachable via:\n>>> http://$VM:3000/\n\n>>> USERNAME: admin\n>>> PASSWORD: admin\n"
