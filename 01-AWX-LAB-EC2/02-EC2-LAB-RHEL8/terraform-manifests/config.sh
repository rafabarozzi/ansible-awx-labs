#! /bin/bash

#Ajustar o timezone
sudo timedatectl set-timezone America/Sao_Paulo

#Hostname Config
sudo hostnamectl set-hostname lab.rbarozzi.com
pubip=$(curl -s ipecho.net/plain)
privip=$(ip addr show eth0 | grep -w inet | awk '{ print $2; }' | cut -d/ -f1)
echo "$pubip    lab.rbarozzi.com  lab" | sudo tee -a /etc/hosts
echo "$privip   lab.rbarozzi.com lab" | sudo tee -a /etc/hosts
echo "127.0.0.1 lab.rbarozzi.com  lab" | sudo tee -a /etc/hosts

# Disabled Selinux
sudo setenforce 0
sudo sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

#Configure EPEL
sudo subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

#Package Updates
sudo yum -y install net-tools
sudo yum -y update

