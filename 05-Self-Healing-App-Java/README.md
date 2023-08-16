## Deploy aplicação Java no Linux

- Instalar o Maven no Linux

``` 
sudo zypper install maven
```

- Compilar e empacotar o código

```
 mvn clean install 
```

 - Copiar para a pasta webapps do tomcat

```
 cp *.war /srv/tomcat/webapps/
```

 - Reiniciar o Tomcat 

```
sudo systemctl restart tomcat
```

- Criar o redirect no apache

```
cd /etc/apache2/vhosts.d
vi self-healing-app.conf

<VirtualHost *:9000>
    ServerName uyuni.rbarozzi.com
	
    SetEnv proxy-nokeepalive 1

    ProxyRequests Off
    ProxyPreserveHost On

    <Proxy *>
        Require all granted
    </Proxy>

    ProxyPass / http://127.0.0.1:8080/self-healing-app/ timeout=600
    ProxyPassReverse / http://127.0.0.1:8080/self-healing-app/

</VirtualHost>
```

- Ativar o serviço de proxy do apache

```
sudo a2enmod proxy
sudo a2enmod proxy_http
```