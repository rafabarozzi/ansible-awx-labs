# Procedimento de Instalação do Docker Hub

```
#Ajustar o timezone
sudo timedatectl set-timezone America/Sao_Paulo

#Hostname Config
sudo hostnamectl set-hostname registry.rbarozzi.com
pubip=$(curl -s ipecho.net/plain)
privip=$(ip addr show eth0 | grep -w inet | awk '{ print $2; }' | cut -d/ -f1)
echo "$pubip    registry.rbarozzi.com  registry" | sudo tee -a /etc/hosts
echo "$privip   registry.rbarozzi.com registry" | sudo tee -a /etc/hosts
echo "127.0.0.1 registry.rbarozzi.com  registry" | sudo tee -a /etc/hosts

# Disabled Selinux
sudo setenforce 0
sudo sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

#Configure EPEL
sudo subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

#Package Updates
sudo yum -y install net-tools lvm2
sudo yum -y update

#Docker Install
sudo dnf remove docker docker-common docker-selinux docker-engine
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf -y install docker-ce
sudo systemctl start docker
sudo systemctl enable docker

#Configurar o insecure registries
vi /etc/docker/daemon.json
{
  "insecure-registries": ["172.31.20.221:5000"]
}

#Executar o container de registry
docker run -d -p 5000:5000 --restart=always --name registry registry:2

#Testar com uma imagem
docker pull redis
docker tag redis:latest 172.31.20.221:5000/redis:latest
docker push 172.31.20.21:5000/redis:latest

#Instalar o NGINX
sudo dnf install nginx

#Instalar o certbot
sudo dnf install certbot python3-certbot-nginx

#Solicitar o certificado para o dominio
sudo certbot certonly --nginx -d dominio.com

#Ativar a renovação automática
sudo certbot renew

#Configurar o NGINX
vi /etc/nginx/conf.d/awx.conf

server {
    listen 80;
    server_name registry.rbarozzi.com; #Substitua pelo seu dominio
    
    # Redirecionar todas as solicitações HTTP para HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name awx.rbarozzi.com; # Substitua pelo seu Dominio

    #Substitua pelo path adequadro em sua VM
    ssl_certificate /etc/letsencrypt/live/registry.rbarozzi.com/fullchain.pem;
    ssl_certificate_key  /etc/letsencrypt/live/registry.rbarozzi.com/privkey.pem;

    # Configurações SSL adicionais, como protocolos e ciphers, podem ser adicionadas aqui
    
    location / {
        proxy_pass http://localhost:5000;  # Porta padrão do contêiner AWX
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

#Baixar o NGINX
sudo systemctl stop nginx
sudo systemctl disable nginx

#Matar os serviços ativos
for pid in $(pgrep nginx); do
    sudo kill $pid
done

#Edit o arquivo nginx.conf e altere as seguintes linhas para a porta 90

    vi /etc/nginx/nginx.conf

  server {
        listen       90 default_server;
        listen       [::]:90 default_server;

#Subir o Serviço
sudo systemctl start nginx
sudo systemctl enable nginx

```