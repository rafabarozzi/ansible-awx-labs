# Repositório de Códigos voltados a laboratório do AWX.

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

## Obter token da API do AWX

``` 
curl -X POST -u admin:password -k https://awx.rbarozzi.com/api/v2/tokens
```

# Ansible no Windows

``` 
#Verificar versão do Python que o Ansible usa
ansible --version

#Pre-reqs
dnf -y install gcc python3-devel krb5-devel krb5-libs krb5-workstation
sudo yum install python3.11-devel
sudo yum groupinstall "Development Tools"

#Instalar o pip3.11
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3.11 get-pip.py

#Instalar pywinrm, kerberos e requests
pip3.11 install pywinrm
pip3.11 install requests
pip3.11 install pywinrm[kerberos]

# Configurando o Kerberos
vi /etc/krb5.conf

[realms]
  rbarozzi.local = {
        kdc = AD.rbarozzi.local
  }

[domain_realm]
    .rbarozzi.local = RBAROZZI.LOCAL

```

## Criar uma estrutura de teste para o playbook

``` 
#Criar uma Pasta
mkdir windows
cd windows

#Criar um arquivo inventario.yml
---
all:
  hosts:
    lab.rbarozzi.local:

#Cria o playbook.yml
---
- name: Criar pasta no Windows
  hosts: lab.rbarozzi.local
  gather_facts: no
  tasks:
    - name: Criar pasta "C:\teste"
      win_shell: New-Item -Path 'C:\teste' -ItemType Directory

#Criar a pasta para o host_vars
mkdir host_vars
cd host_vars

#Criar o arquivo lab.rbarozzi.local.yml
---
ansible_user: rafael@RBAROZZI.LOCAL
ansible_password: senhaaqui
ansible_connection: winrm
ansible_port: 5985
ansible_winrm_transport: kerberos
```

## LDAP Config

``` 
LDAP Server URI
ldap://172.31.63.27

LDAP Bind DN
CN=adm adm,CN=Users,DC=rbarozzi,DC=local

LDAP Group Type
MemberDNGroupType

LDAP Require Group
CN=adm-awx,OU=User,DC=rbarozzi,DC=local

LDAP User Search
[
  "OU=User,DC=rbarozzi,DC=local",
  "SCOPE_SUBTREE",
  "(cn=%(user)s)"
]

LDAP Group Search
[
  "dc=rbarozzi,dc=local",
  "SCOPE_SUBTREE",
  "(objectClass=group)"
]

LDAP User Attribute Map
{
  "first_name": "givenName",
  "last_name": "sn",
  "email": "mail"
}

LDAP Group Type Parameters
{
  "member_attr": "member",
  "name_attr": "cn"
}

LDAP User Flags By Group
{
  "is_superuser": [
    "CN=adm-awx,OU=User,DC=rbarozzi,DC=local"
  ]
}

``` 