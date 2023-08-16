#! /bin/bash


#Ajustar o timezone
sudo timedatectl set-timezone America/Sao_Paulo

# Disabled Selinux
sudo setenforce 0
sudo sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

#Configure EPEL
sudo subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

#Package Updates
sudo yum install net-tools -y
sudo yum -y update

#Hostname Config
sudo hostnamectl set-hostname lab.rbarozzi.com
pubip=$(curl -s ipecho.net/plain)
privip=$(ip addr show eth0 | grep -w inet | awk '{ print $2; }' | cut -d/ -f1)
echo "$pubip    lab.rbarozzi.com  lab" | sudo tee -a /etc/hosts
echo "$privip   lab.rbarozzi.com lab" | sudo tee -a /etc/hosts
echo "127.0.0.1 lab.rbarozzi.com  lab" | sudo tee -a /etc/hosts

sudo dnf install -y https://repo.zabbix.com/zabbix/4.4/rhel/8/x86_64/zabbix-release-4.4-1.el8.noarch.rpm
dnf install -y zabbix-agent

sudo firewall-cmd --permanent --add-port=10050/tcp
sudo firewall-cmd --reload

sudo systemctl enable zabbix-agent


