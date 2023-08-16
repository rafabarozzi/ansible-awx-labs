# Provisioning EC2 Instance and Install AWX

## Prerequisites

- Terraform *https://www.terraform.io/downloads.html*
- AWS CLI *https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html*
- AWS EC2 Keypair *https://docs.aws.amazon.com/servicecatalog/latest/adminguide/getstarted-keypair.html*
## Resources created

- 1 EC2 Instance (RHEL8) m5.larger with Public IP
- 2 Security Groups (SSH and Web)
- 1 EBS volume of 200 GB for AWX use

## How to Use

1. Clone the repository: Clone this repository to your local machine using the following command:

```
git clone https://github.com/rafabarozzi/terraform-on-aws.git
```

2. Navigate to correct folder

```
cd 01-ec2-ansible-rhel8-basic/terraform-manifest
```

3. Copy your Key pair to Folder *private-key*

4. Edit the Files

```
t2-varibles.tf
Configure your KeyPair
```

5. Initialize Terraform

```
terraform init
```

6. Run code verification

```
terraform plan
```

7. Apply the Terraform configuration

```
terraform apply -auto-approve
```

**Access AWX using DNS configured in t7-route53-records.tf**

*Example: http://awx.rbarozzi.com*

- **User:** *admin*
- **Pass:** *password*

8. Destroy the infrastructure

```
terraform destroy -auto-approve
```

**Please be cautious while using the *terraform destroy* command, as it will permanently delete the resources provisioned by Terraform.**

## Configuração do Nginx

 - Alterar a porta 80 para 8080 no inbound do container

```
vi /var/lib/awx/awxcompose/docker-compose.yml

#Reiniciar os containers

docker-compose down
docker-compose up -d
```

- Instalar o nginx 

``` 
sudo dnf install nginx
```
 
- Caso for usar o lets encrypt é necessário instalar o certbot

``` 
#Iinstalar o certbot
sudo dnf install certbot python3-certbot-nginx

#Solicitar o certificado para o dominio
sudo certbot certonly --nginx -d dominio.com

#Ativar a renovação automática
sudo certbot renew
```

- Configurar o nginx 

``` 
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

```

- Baixar o nginx

``` 
sudo systemctl stop nginx
sudo systemctl disable nginx
```

- Matar todos os serviços do nginx ativos

```
for pid in $(pgrep nginx); do
    sudo kill $pid
done
```

- Alterar a porta padrão do nginx

``` 
#Edit o arquivo nginx.conf e altere as seguintes linhas para a porta 90

    vi /etc/nginx/nginx.conf

  server {
        listen       90 default_server;
        listen       [::]:90 default_server;

```

- Suba novamente o serviço 

```
sudo systemctl start nginx
sudo systemctl enable nginx
```

## Configurar conexão SSH com o GitLab

``` 
ssh-keygen -t rsa -b 4096 -c "rafael.barozzi@gmail.com"
```

- No Gitlab 
``` 
-> No topo do Menu Esquerdo clique no ícone da sua Conta
-> Preferences
-> SSH Keys
-> Add New Key
```

- No Awx
``` 
-> Crie uma credential do tipo Machine
-> Nome do Usuário: Git
- SSH Private Key: Cole a Chave 
```

# Configurar Autenticação SSO com o Azure AD

1. Azure AD -> App Registration -> New Registration 

``` 
Name: AwxAppSSO
Account Type: Accounts in any organizational directory (Any Azure AD directory - Multitenant)
```

2. Copiar Application (client) ID e ir ao AWX
3. AWX -> Settings -> Azure AD settings -> Edit -> Azure AD OAuth2 Key (Cole Aqui)
4. Azure AD -> Dentro da App Criada no Passo 1 -> Certificates & Secrets -> New Client Secret
5. Copie o Value gerado no passo 4
6. AWX -> Ainda nas configurações do Azure AD settings -> Edit -> Azure AD OAuth2 Secret (Cola aqui)
7. Azure AD -> Dentro da App Criada no Passo 1 -> Authentication -> Add a platform -> Web - Redirect URL
8. A redirect URL é https://fqdn//sso/complete/azuread-oauth2/ 
```
Exemplo: https://awx.rbarozzi.com/sso/complete/azuread-oauth2/ 
```

**SSO Configurado**

**Obs.:** *Na tela de Login do AWX clicar no icone do Azure AD abaixo do botão Login*


## Configurar a Conexão entre os hosts

- No AWX Server

``` 
#Criar o usuário AWX
adduser -u 10000 awx

#Adicionar uma senha
passwd awx

#Logar como AWX
sudo su - awx

#Gerar o par de chaves
ssh-keygen -t rsa -b 4096

Obs.: Inserir o Passphare para a chave SSH

#Copiar o hash de senha do usuáro AWX
cat /etc/shadow

```

- Nos hosts remotos

``` 
#Criar o usuário AWX 
sudo useradd -u 10000 -m -p '<HASH_AQUI>' awx

#Adicionar o AWX no Sudoers
sudo usermod -aG wheel awx

#Conectar como AWX
sudo su - awx

# Crie o diretório .ssh e configure as permissões corretas
mkdir ~/.ssh
chmod 700 ~/.ssh

# Copie a chave pública do host local para o arquivo authorized_keys
echo "COLE_AQUI_A_CHAVE_PÚBLICA" > ~/.ssh/authorized_keys

# Configure as permissões corretas para o arquivo authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

- Senhas configuradas no Ambiente
``` 
#Chave SSH

A*MI3jZx@77BffSGW84eh

#User AWX
W@k1RREInG*q2lDmY2tF0
```



Instance Group --> Iventario -> Host --> Adicionar ao Instance Group 