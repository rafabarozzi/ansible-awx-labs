#! /bin/bash

#Ajustar o timezone
sudo timedatectl set-timezone America/Sao_Paulo

#Disabled Selinux
sudo setenforce 0
sudo sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

#Hostname Config
sudo hostnamectl set-hostname uyuni.rbarozzi.com
pubip=$(curl -s ipecho.net/plain)
privip=$(ip addr show eth0 | grep -w inet | awk '{ print $2; }' | cut -d/ -f1)
echo "$pubip    uyuni.rbarozzi.com  uyuni" | sudo tee -a /etc/hosts
echo "$privip   uyuni.rbarozzi.com uyuni" | sudo tee -a /etc/hosts
echo "127.0.0.1 uyuni.rbarozzi.com  uyuni" | sudo tee -a /etc/hosts

#Instalar o Git
sudo zypper install git -y

#Disk Mounting
sudo pvcreate /dev/xvdb
sudo vgcreate vgunyuni /dev/xvdb
sudo lvcreate -L 110G -n lvpgsql vgunyuni
sudo lvcreate -L 110G -n lvspacewalk vgunyuni
sudo lvcreate -L 15G -n lvcache vgunyuni
sudo lvcreate -L 5G -n swaplv vgunyuni
sudo mkfs.ext4 /dev/mapper/vgunyuni-lvpgsql
sudo mkfs.ext4 /dev/mapper/vgunyuni-lvspacewalk
sudo mkfs.ext4 /dev/mapper/vgunyuni-lvcache
sudo mkfs.ext4 /dev/mapper/vgunyuni-swaplv
sudo mkdir -p /var/lib/pgsql
sudo mkdir -p /var/spacewalk
sudo mkdir -p /var/cache
sudo mkdir /swap

sudo echo "/dev/mapper/vgunyuni-lvpgsql /var/lib/pgsql ext4 defaults 0 0" | sudo tee -a /etc/fstab
sudo echo "/dev/mapper/vgunyuni-lvspacewalk /var/spacewalk ext4 defaults 0 0" | sudo tee -a /etc/fstab
sudo echo "/dev/mapper/vgunyuni-lvcache /var/cache ext4 defaults 0 0" | sudo tee -a /etc/fstab
sudo echo "/dev/mapper/vgunyuni-swaplv /swap ext4 defaults 0 0" | sudo tee -a /etc/fstab

sudo mount -a

sudo fallocate -l 4G /swap/swapfile
sudo chmod 600 /swap/swapfile
sudo mkswap /swap/swapfile
sudo swapon /swap/swapfile

sudo echo "/swap/swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab
mount -a

#Set variables to use to create repository
repo=repositories/systemsmanagement:/
repo=${repo}Uyuni:/Stable/images/repo/Uyuni-Server-POOL-x86_64-Media1/

#Add the repository for installing the Uyuni Server
sudo zypper ar https://download.opensuse.org/$repo uyuni-server-stable

#Refresh repos
sudo zypper --gpg-auto-import-keys ref

#Install Uyuni-Server
sudo zypper --non-interactive --gpg-auto-import-keys in patterns-uyuni_server

echo "export MANAGER_FORCE_INSTALL='0'" >> /root/setup_env.sh
echo "export ACTIVATE_SLP='n'" >> /root/setup_env.sh
echo "export MANAGER_ADMIN_EMAIL='rafael.barozzi@gmail.com'" >> /root/setup_env.sh
echo "export MANAGER_ENABLE_TFTP='y'" >> /root/setup_env.sh
echo "export MANAGER_IP='$privip'" >> /root/setup_env.sh
echo "export MANAGER_DB_PORT='5432'" >> /root/setup_env.sh
echo "export DB_BACKEND='postgresql'" >> /root/setup_env.sh
echo "export MANAGER_DB_HOST='localhost'" >> /root/setup_env.sh
echo "export MANAGER_DB_NAME='uyuni'" >> /root/setup_env.sh
echo "export MANAGER_DB_PROTOCOL='TCP'" >> /root/setup_env.sh
echo "export MANAGER_PASS='dbpassword11'" >> /root/setup_env.sh
echo "export MANAGER_PASS2='dbpassword11'" >> /root/setup_env.sh
echo "export MANAGER_USER='uyuni'" >> /root/setup_env.sh
echo "export LOCAL_DB='1'" >> /root/setup_env.sh
echo "export CERT_CITY='Itajobi'" >> /root/setup_env.sh
echo "export CERT_COUNTRY='BR'" >> /root/setup_env.sh
echo "export CERT_EMAIL='rafael.barozzi@gmail.com'" >> /root/setup_env.sh
echo "export CERT_O='Barozzi'" >> /root/setup_env.sh
echo "export CERT_OU='Barozzi'" >> /root/setup_env.sh
echo "export CERT_PASS='1234567890'" >> /root/setup_env.sh
echo "export CERT_PASS2='1234567890'" >> /root/setup_env.sh
echo "export CERT_STATE='SP'" >> /root/setup_env.sh

sudo /usr/lib/susemanager/bin/mgr-setup -s


