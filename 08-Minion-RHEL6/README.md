## Instalar o Minion no RHEL 6

```
#Criar o repo do salt
sudo vi /etc/yum.repos.d/salt.repo

[salt]
name=SaltStack Repository
baseurl=https://archive.repo.saltproject.io/yum/redhat/6/x86_64/2019.2/
enabled=1
gpgcheck=1
gpgkey=https://archive.repo.saltproject.io/yum/redhat/6/x86_64/2019.2/SALTSTACK-GPG-KEY.pub

#Atualizar metadados dos repos
sudo yum clean all
sudo yum makecache

#Instalar o Salt
sudo yum install salt-minion
```



