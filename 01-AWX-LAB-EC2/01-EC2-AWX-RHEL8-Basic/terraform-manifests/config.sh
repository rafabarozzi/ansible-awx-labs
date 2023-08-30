#! /bin/bash

cd /home/ec2-user/

#Ajustar o timezone
sudo timedatectl set-timezone America/Sao_Paulo

#Hostname Config
sudo hostnamectl set-hostname awx.rbarozzi.com
pubip=$(curl -s ipecho.net/plain)
privip=$(ip addr show eth0 | grep -w inet | awk '{ print $2; }' | cut -d/ -f1)
echo "$pubip    awx.rbarozzi.com  awx" | sudo tee -a /etc/hosts
echo "$privip   awx.rbarozzi.com awx" | sudo tee -a /etc/hosts
echo "127.0.0.1 awx.rbarozzi.com  awx" | sudo tee -a /etc/hosts

# Disabled Selinux
sudo setenforce 0
sudo sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

#Configure EPEL
sudo subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

#Package Updates
sudo yum -y install net-tools
sudo yum -y update

#Installing Dependencies
sudo dnf install -y make git gcc gcc-c++ nodejs gettext device-mapper-persistent-data lvm2 bzip2 python3-pip ansible

#Docker Install
sudo dnf remove docker docker-common docker-selinux docker-engine
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf -y install docker-ce
sudo systemctl start docker
sudo systemctl enable docker


#Python3.8 Install
sudo yum -y install python3.8

#Setting Python3 as default
sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
sudo echo 3 | sudo alternatives --config python3

#Docker-compose Install
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo docker-compose --version
sudo pip3.8 install docker-compose

#Clone the AWX repo
sudo git clone -b "17.1.0" https://github.com/ansible/awx.git

#Generate a key
awxkey=$(openssl rand -base64 30)

#Backup of the original inventory file
cd /home/ec2-user/awx/installer/
sudo cat inventory >> inventory.bkp
sudo echo > inventory

#Disk Mounting
sudo pvcreate /dev/nvme1n1
sudo vgcreate awxvg /dev/nvme1n1
sudo lvcreate -L 50G -n awxlv awxvg
sudo lvcreate -L 5G -n swaplv awxvg
sudo mkfs.xfs /dev/mapper/awxvg-awxlv
sudo mkfs.xfs /dev/mapper/awxvg-swaplv
sudo mkdir -p /var/lib/awx
sudo mkdir /swap

sudo echo "/dev/mapper/awxvg-awxlv /var/lib/awx xfs defaults 0 0" | sudo tee -a /etc/fstab
sudo echo "/dev/mapper/awxvg-swaplv /swap xfs defaults 0 0" | sudo tee -a /etc/fstab

sudo mount -a

sudo fallocate -l 4G /swap/swapfile
sudo chmod 600 /swap/swapfile
sudo mkswap /swap/swapfile
sudo swapon /swap/swapfile

sudo echo "/swap/swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab
mount -a

#Updating the inventory file

sudo echo "localhost ansible_connection=local ansible_python_interpreter=\"/usr/bin/env python3\"" >> inventory
sudo echo "" >> inventory
sudo echo "[all:vars]" >> inventory
sudo echo "dockerhub_base=ansible" >> inventory
sudo echo "awx_task_hostname=awx" >> inventory
sudo echo "awx_web_hostname=awxweb" >> inventory
sudo echo "postgres_data_dir=\"/var/lib/awx/pgdocker\"" >> inventory
sudo echo "host_port=80" >> inventory
sudo echo "host_port_ssl=443" >> inventory
sudo echo "docker_compose_dir=\"/var/lib/awx/awxcompose\"" >> inventory
sudo echo "pg_username=awx" >> inventory
sudo echo "pg_password=awxpassword" >> inventory
sudo echo "pg_database=awx" >> inventory
sudo echo "pg_port=5432" >> inventory
sudo echo "admin_user=admin" >> inventory
sudo echo "admin_password=password" >> inventory
sudo echo "create_preload_data=True" >> inventory
sudo echo "secret_key=\"$awxkey\"" >> inventory
sudo echo "awx_official=false" >> inventory

sudo ansible-playbook -i /home/ec2-user/awx/installer/inventory /home/ec2-user/awx/installer/install.yml

