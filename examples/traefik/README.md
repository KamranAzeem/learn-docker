# The ultimate guide on Traefik

In this guide, I will show various ways traefik can be used as a reverse proxy for your (back-end) containers, on Docker (compose) and Kubernetes.

**Note:** The Kubernetes stuff will be in this file - temporarily, but will later move to the learn-kubernetes repository.

* Traefik running as a service, working as reverse proxy for tomcat:8080, jenkins:8080
 * SSL with self signed certificates in traefik instead of tomcat
 * script to create self signed certs
* Traefik running in docker-compose with tomcat:8080, and jenkins:8080
* Traefik running as reverse proxy for two different websites www.example.com, www.example.net,


# VM:

## traefik in front of Tomcat / Jenkins- VM
Any one will do for the sake of example, I will show tomcat only.

First, install Tomcat. 
```
[root@centos7 ~]# yum -y install tomcat


```

Note, both tomcat and jenkins use port 8080, so they cannot run at the same time, unless you change the listening port of one of them, then you can run both.

```
[root@centos7 ~]# systemctl start tomcat


[root@centos7 ~]# systemctl status tomcat
● tomcat.service - Apache Tomcat Web Application Container
   Loaded: loaded (/usr/lib/systemd/system/tomcat.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2019-01-20 09:40:45 EST; 5s ago
 Main PID: 3402 (java)
   CGroup: /system.slice/tomcat.service
           └─3402 /usr/lib/jvm/jre/bin/java -classpath /usr/share/tomcat/bin/bootstrap.jar:/usr/share/tomcat/bin/tomcat-juli.jar:/usr...

Jan 20 09:40:46 centos7 server[3402]: Jan 20, 2019 9:40:46 AM org.apache.catalina.core.StandardService startInternal
Jan 20 09:40:46 centos7 server[3402]: INFO: Starting service Catalina
Jan 20 09:40:46 centos7 server[3402]: Jan 20, 2019 9:40:46 AM org.apache.catalina.core.StandardEngine startInternal
Jan 20 09:40:46 centos7 server[3402]: INFO: Starting Servlet Engine: Apache Tomcat/7.0.76
Jan 20 09:40:46 centos7 server[3402]: Jan 20, 2019 9:40:46 AM org.apache.coyote.AbstractProtocol start
Jan 20 09:40:46 centos7 server[3402]: INFO: Starting ProtocolHandler ["http-bio-8080"]
Jan 20 09:40:46 centos7 server[3402]: Jan 20, 2019 9:40:46 AM org.apache.coyote.AbstractProtocol start
Jan 20 09:40:46 centos7 server[3402]: INFO: Starting ProtocolHandler ["ajp-bio-8009"]
Jan 20 09:40:46 centos7 server[3402]: Jan 20, 2019 9:40:46 AM org.apache.catalina.startup.Catalina start
Jan 20 09:40:46 centos7 server[3402]: INFO: Server startup in 92 ms
[root@centos7 ~]# 

[root@centos7 ~]# netstat -ntlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      3150/sshd           
tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      3256/master         
tcp6       0      0 :::8009                 :::*                    LISTEN      3402/java           
tcp6       0      0 :::8080                 :::*                    LISTEN      3402/java           
tcp6       0      0 :::22                   :::*                    LISTEN      3150/sshd           
tcp6       0      0 ::1:25                  :::*                    LISTEN      3256/master         
tcp6       0      0 127.0.0.1:8005          :::*                    LISTEN      3402/java           
[root@centos7 ~]# 
```

Make sure firewall is disabled.


Download a sample war file and place it in tomcat.

[root@centos7 ~]# curl -LO https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war


[root@centos7 ~]# cp sample.war /usr/share/tomcat/webapps/



Set a name for this vm in /etc/hosts, say tomcat.example.com , on host computer.


(screen shot from browser)




Download the latest version of traffic from: https://github.com/containous/traefik/releases . It is a single binary file, so just download and place it in /usr/local/bin/ or somewhere else you like. It is about 60-70 MB in size.

```
[root@centos7 ~]# chmod +x traefik_linux-amd64 
[root@centos7 ~]# cp traefik_linux-amd64 /usr/local/bin/traefik
```

Download the sample traefik config file from: https://raw.githubusercontent.com/containous/traefik/master/traefik.sample.toml , and place in it /usr/local/etc/

```
[root@centos7 ~]# curl -LO https://raw.githubusercontent.com/containous/traefik/master/traefik.sample.toml
[root@centos7 ~]# cp traefik.sample.toml /usr/local/etc/traefik.toml
```

Adjust the traefik config file:

```
[root@centos7 ~]# grep -v \# /usr/local/etc/traefik.toml  | egrep -v "^$"
[entryPoints]
    [entryPoints.http]
    address = ":80"
    [entryPoints.dashboard]
    address = ":8090"
      [entryPoints.dashboard.auth.basic]
      users = ["admin:$2y$08$64hQda74gXS80mS63hN3xOFGVB9KA2vUOXtW.NDaBjX9pEHq7qdUa"]
[file]
  [frontends]
    [frontends.tomcat]
    backend = "tomcat"
      [frontends.tomcat.routes.test_1]
      rule = "Host: tomcat.example.com"
  [backends]
    [backends.tomcat]
      [backends.tomcat.servers.server1]
      url = "http://127.0.0.1:8080"
[api]
  dashboard = true
  entryPoint = "dashboard"
[ping]
  entrypoint = "dashboard"
[root@centos7 ~]# 
```

Since we have tomcat running on the same VM on port 8080, we can't run traefik's dashboard on 8080. So we change it to 8090.

Also, since this is a plain VM, we need to setup frontend and backend so traefik would know how to flow traffic. The special "file" directive is used for that. We can also setup traffic to watch an external rules file which contains the frontends and beckends routing. Of-course none of this is needed (normally) if traefik is talking to docker or kubernetes API. In our case in this particular example, we have neither docker, nor kubernetes - just plain simple VM.


Create a systemd service file for Traefik. Not entirely necessary though.

```
[root@centos7 ~]# vi traefik.service

[Unit]
Description=Traefik reverse proxy / edge router

[Service]
Type=simple
ExecStart=/usr/local/bin/traefik  --configFile=/usr/local/etc/traefik.toml


[Install]
WantedBy=multi-user.target
```


```
[root@centos7 ~]# cp traefik.service /etc/systemd/system/
[root@centos7 ~]# systemctl daemon-reload
```


Two Screenshots , one with traffic dashboard, and the other with tomcat without 8080.

## Basic Authentication¶

It is important to secure the dashboard with some authentication. 

Passwords can be encoded in MD5, SHA1 and BCrypt: you can use htpasswd to generate them.

Users can be specified directly in the TOML file, or indirectly by referencing an external file; if both are provided, the two are merged, with external file contents having precedence.

```
[entryPoints.dashboard.auth.basic]
  users = ["admin:$2y$08$64hQda74gXS80mS63hN3xOFGVB9KA2vUOXtW.NDaBjX9pEHq7qdUa"]
```


```
[root@centos7 ~]# htpasswd -B -C 8 -n admin
New password: 
Re-type new password: 
admin:$2y$08$64hQda74gXS80mS63hN3xOFGVB9KA2vUOXtW.NDaBjX9pEHq7qdUa

[root@centos7 ~]# 
```
**notes:** 
* -B = use Bcrypt (Secure)
* -C = BCrypt compute time / difficulty level (4-31)
* -n = username
* password = secret


(show screenshot with auth)


# Docker-compose:






