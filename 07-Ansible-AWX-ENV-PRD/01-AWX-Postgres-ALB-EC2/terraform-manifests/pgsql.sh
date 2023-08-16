#! /bin/bash

#Reiniciar o serviço do resolved
sudo systemctl restart systemd-resolved

#Ajustar o timezone
sudo timedatectl set-timezone America/Sao_Paulo

# Disabled Selinux
sudo setenforce 0
sudo sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

#Configure EPEL
sudo subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

#Package Updates
sudo yum install net-tools lvm2 -y
sudo yum -y update

#Hostname Config
sudo hostnamectl set-hostname pgsql.rbarozzi.com
privip=$(ip addr show eth0 | grep -w inet | awk '{ print $2; }' | cut -d/ -f1)
echo "$privip   pgsql.rbarozzi.com pgsql" | sudo tee -a /etc/hosts
echo "127.0.0.1 pgsql.rbarozzi.com  pgsql" | sudo tee -a /etc/hosts


#Disk Mounting
sudo pvcreate /dev/nvme1n1
sudo vgcreate pgvg /dev/nvme1n1
sudo lvcreate -L 50G -n pglv pgvg
sudo lvcreate -L 5G -n swaplv pgvg
sudo mkfs.xfs /dev/mapper/pgvg-pglv
sudo mkfs.xfs /dev/mapper/pgvg-swaplv
sudo mkdir -p /var/lib/awx
sudo mkdir /swap

sudo echo "/dev/mapper/pgvg-pglv /var/lib/pgsql xfs defaults 0 0" | sudo tee -a /etc/fstab
sudo echo "/dev/mapper/pgvg-swaplv /swap xfs defaults 0 0" | sudo tee -a /etc/fstab

sudo mount -a

sudo fallocate -l 4G /swap/swapfile
sudo chmod 600 /swap/swapfile
sudo mkswap /swap/swapfile
sudo swapon /swap/swapfile

sudo echo "/swap/swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab
mount -a

#Instalar o Postgres
sudo dnf install postgresql-server -y

#Habilitar o Postgres no boot
sudo systemctl enable postgresql

#Iniciar o DB
sudo /usr/bin/postgresql-setup --initdb

#Reiniciar o PostgreSQL
sudo systemctl restart postgresql

#Ativar o Listen para All
echo "listen_addresses = '*'" | sudo tee -a /var/lib/pgsql/data/postgresql.conf

#Backup do pg_hba
sudo cat /var/lib/pgsql/data/pg_hba.conf > /var/lib/pgsql/data/pg_hba.conf.bkp

#Reiniciar o serviço do resolved
sudo systemctl restart systemd-resolved

# Capturando o IP do Servidor AWX
ping_result=$(ping -c 1 awx-server.rbarozzi.com)
ip_address=$(echo "$ping_result" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)

#Inserir no pg_hba.conf
pg_hba_file="/var/lib/pgsql/data/pg_hba.conf"
line_to_insert="host    all             all             $ip_address/32            md5"
echo "$line_to_insert" | sudo tee -a "$pg_hba_file"

#Reiniciar o PostgreSQL
sudo systemctl restart postgresql

#Configurando o postgres
sudo su - postgres <<EOF
psql -c "ALTER USER postgres WITH PASSWORD 'sua_senha_aqui';"
psql -U postgres -c "CREATE DATABASE awx;"
psql -U postgres -d awx -c "CREATE USER awx WITH PASSWORD 'awxpassword';"
psql -U postgres -d awx -c "GRANT ALL PRIVILEGES ON DATABASE awx TO awx;"
EOF






