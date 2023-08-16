#! /bin/bash

#Ajustar o timezone
sudo timedatectl set-timezone America/Sao_Paulo

#Configure Hostname and FQDN
sudo hostnamectl set-hostname zabbix.rbarozzi.com
privip=$(ip addr show eth0 | grep -w inet | awk '{ print $2; }' | cut -d/ -f1)
echo "$privip   zabbix.rbarozzi.com zabbix" | sudo tee -a /etc/hosts
echo "127.0.0.1 zabbix.rbarozzi.com  zabbix" | sudo tee -a /etc/hosts


#Install Zabbix Repo
sudo wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu22.04_all.deb sudo wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu22.04_all.deb 
sudo dpkg -i zabbix-release_6.0-4+ubuntu22.04_all.deb 
sudo apt update 

#Install mysql-server
sudo apt install mysql-server -y
sudo systemctl start mysql
sudo systemctl enable mysql

#Install Zabbix Packages
sudo apt install zabbix-server-mysql zabbix-agent zabbix-apache-conf zabbix-sql-scripts  zabbix-frontend-php -y

#Create Database
sudo mysql -uroot <<EOF
create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user zabbix@localhost identified by 'password';
grant all privileges on zabbix.* to zabbix@localhost;
set global log_bin_trust_function_creators = 1;
EOF

#Import the initial schema
MYSQL_USER='zabbix'
MYSQL_PASSWORD='password'
MYSQL_DB='zabbix'
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DB

#Disable Log
mysql -uroot <<EOF
set global log_bin_trust_function_creators = 0;
EOF

#Configure DBpassword 
sudo echo "DBPassword=password" | sudo tee -a /etc/zabbix/zabbix_server.conf

#Restart Services
sudo systemctl restart zabbix-server zabbix-agent apache2 
sudo systemctl enable zabbix-server zabbix-agent apache2 

# #Redirect zabbix.rbarozzi.com to zabbix.rbarozzi.com/zabbbix
# sudo sed -i '/DocumentRoot \/var\/www\/html\//a \\tRewriteEngine on\n \tRewriteCond %{HTTP_HOST} ^zabbix\\.rbarozzi\\.com$\n \tRewriteRule ^/$ /zabbix/ [R=301,L]' /etc/apache2/sites-available/000-default.conf

# #Activate rewrite
# sudo a2enmod rewrite
# sudo systemctl restart apache2
