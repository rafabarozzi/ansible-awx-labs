## Uyuni Server

```
#Gerar Chave SSH

ssh-keygen -t rsa

# Adicionar no authorized_keys dos demais server (zabbix e lab)
# Adicionar um alias para os servers no /etc/hosts

#Listar os Channels
spacewalk-common-channels -l

#Visualizar logs do sync dos repos
tail -f /var/log/rhn/reposync/$repo.log

#Criar Channel CentOS8
/usr/bin/spacewalk-common-channels -u admin -p r4f40421 -a x86_64 'centos8*'

#Criar o Bootstrap repo
mgr-create-bootstrap-repo

#Criar o link simbólico do bootstrap para RHEL8
cd /srv/www/htdocs/pub/repositories/
ln -s centos/ res

#Arquivos de config dos repos e uyuni
cd /etc/rhn

```

## Client

```
#Restart Minion

systemctl restart venv-salt-minion.service

#Log 

tail -f /var/log/venv-salt-minion.log 

#Arquivo de Conf

vi /etc/venv-salt-minion/minion/susemanager.conf

```

## Setup Jenkins

**Acessar:** http://jenkins.rbarozzi.com:8080

- Obter a senha inicial

``` 
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

## Configure Zabbix Agent

``` 
vi /etc/zabbix/zabbix_agentd.conf

Server=ip_do_server
Hostname=Hostname_do_server
```

