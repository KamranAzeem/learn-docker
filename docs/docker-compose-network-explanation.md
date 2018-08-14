Here is how the application's (compose) network looks like when inspected.
```
[kamran@kworkhorse compose]$ docker network inspect compose_webdbnet
[
    {
        "Name": "compose_webdbnet",
        "Id": "1a05d2c88beca8d011164522074df99ee9c659d0027e3c86747536c33d3c8aee",
        "Created": "2018-08-12T01:26:48.423820843+02:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.20.0.0/16",
                    "Gateway": "172.20.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": true,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "2599f4218d28854d0e514a958d0962f7ff1bba1371b5c8182396b73841ce4b92": {
                "Name": "compose_nginx_1",
                "EndpointID": "7f687d1232c62c39ecc502f5d5ad493f61f921387e86e7c2135dbb41b97fa21c",
                "MacAddress": "02:42:ac:14:00:04",
                "IPv4Address": "172.20.0.4/16",
                "IPv6Address": ""
            },
            "a940aa8345ce921fa43e47cb09e9b91adb1a4b83be8f820ca33771416df50b01": {
                "Name": "compose_web_1",
                "EndpointID": "035765dcb80e25afc120d3769236353ab93ccea8e7c3c5eef0003101f1e1ff6f",
                "MacAddress": "02:42:ac:14:00:03",
                "IPv4Address": "172.20.0.3/16",
                "IPv6Address": ""
            },
            "b019610df0f7a0bb36c351960f9e1c62cfce376f2784bc870c06f4a8d049f54b": {
                "Name": "compose_db_1",
                "EndpointID": "2ee173e784b0fe61d827796f845b90aa53e2ffdb5f7a124cfc99072729218dcb",
                "MacAddress": "02:42:ac:14:00:02",
                "IPv4Address": "172.20.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {
            "com.docker.compose.network": "webdbnet",
            "com.docker.compose.project": "compose"
        }
    }
]
[kamran@kworkhorse compose]$
```

This shows the sockets on which various services are listening on my host computer:
```
[kamran@kworkhorse compose]$ netstat -ntlp
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 127.0.0.1:5939          0.0.0.0:*               LISTEN      -                   
tcp        0      0 10.240.0.1:53           0.0.0.0:*               LISTEN      -                   
tcp        0      0 192.168.122.1:53        0.0.0.0:*               LISTEN      -                   
tcp        0      0 127.0.0.1:631           0.0.0.0:*               LISTEN      -                   
tcp        0      0 192.168.0.14:10010      0.0.0.0:*               LISTEN      -                   
tcp6       0      0 :::80                   :::*                    LISTEN      -                   
tcp6       0      0 ::1:631                 :::*                    LISTEN      -                   
tcp6       0      0 :::443                  :::*                    LISTEN      -                   
[kamran@kworkhorse compose]$
```

Simple output of docker ps, showing running containers:
```
[kamran@kworkhorse compose]$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                      NAMES
2599f4218d28        compose_nginx       "nginx -g 'daemon of…"   10 hours ago        Up 10 hours         0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   compose_nginx_1
a940aa8345ce        compose_web         "docker-php-entrypoi…"   10 hours ago        Up 10 hours         80/tcp                                     compose_web_1
b019610df0f7        mysql:latest        "docker-entrypoint.s…"   10 hours ago        Up 10 hours         3306/tcp                                   compose_db_1
[kamran@kworkhorse compose]$
```


The following shows all of the network interfaces on my host computer. Interface # `45` `br-1a05d2c88bec` is the one, on which my containers from the *compose* app are conntected.
```
[kamran@kworkhorse compose]$ ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: wlp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 34:f3:9a:27:e7:2d brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.14/24 brd 192.168.0.255 scope global dynamic wlp2s0
       valid_lft 2508836sec preferred_lft 2508836sec
    inet6 fe80::d49c:8c86:881e:e720/64 scope link 
       valid_lft forever preferred_lft forever
3: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 52:54:00:d2:3b:7c brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
       valid_lft forever preferred_lft forever
4: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel master virbr0 state DOWN group default qlen 1000
    link/ether 52:54:00:d2:3b:7c brd ff:ff:ff:ff:ff:ff
5: virbr2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 52:54:00:0a:2a:10 brd ff:ff:ff:ff:ff:ff
    inet 10.240.0.1/16 brd 10.240.255.255 scope global virbr2
       valid_lft forever preferred_lft forever
6: virbr2-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel master virbr2 state DOWN group default qlen 1000
    link/ether 52:54:00:0a:2a:10 brd ff:ff:ff:ff:ff:ff
7: virbr1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 52:54:00:31:4c:6d brd ff:ff:ff:ff:ff:ff
    inet 192.168.39.1/24 brd 192.168.39.255 scope global virbr1
       valid_lft forever preferred_lft forever
8: virbr1-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel master virbr1 state DOWN group default qlen 1000
    link/ether 52:54:00:31:4c:6d brd ff:ff:ff:ff:ff:ff
9: br-78f542b5425d: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:52:39:fa:40 brd ff:ff:ff:ff:ff:ff
    inet 172.19.0.1/16 brd 172.19.255.255 scope global br-78f542b5425d
       valid_lft forever preferred_lft forever
10: br-9a7f736814a4: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:1d:92:5a:26 brd ff:ff:ff:ff:ff:ff
    inet 172.18.0.1/16 brd 172.18.255.255 scope global br-9a7f736814a4
       valid_lft forever preferred_lft forever
11: br-c0a4fe39ae32: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:2b:19:d2:18 brd ff:ff:ff:ff:ff:ff
    inet 172.22.0.1/16 brd 172.22.255.255 scope global br-c0a4fe39ae32
       valid_lft forever preferred_lft forever
12: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:1f:cc:a3:48 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:1fff:fecc:a348/64 scope link 
       valid_lft forever preferred_lft forever
13: br-3043e91f853b: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:61:4e:a1:67 brd ff:ff:ff:ff:ff:ff
    inet 172.21.0.1/16 brd 172.21.255.255 scope global br-3043e91f853b
       valid_lft forever preferred_lft forever
14: br-3442b34e12b8: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:fb:9b:60:8f brd ff:ff:ff:ff:ff:ff
    inet 172.16.238.1/24 brd 172.16.238.255 scope global br-3442b34e12b8
       valid_lft forever preferred_lft forever
45: br-1a05d2c88bec: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:85:1d:e6:e9 brd ff:ff:ff:ff:ff:ff
    inet 172.20.0.1/16 brd 172.20.255.255 scope global br-1a05d2c88bec
       valid_lft forever preferred_lft forever
    inet6 fe80::42:85ff:fe1d:e6e9/64 scope link 
       valid_lft forever preferred_lft forever
62: br-9d8122a452e5: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:ac:56:02:67 brd ff:ff:ff:ff:ff:ff
    inet 172.23.0.1/16 brd 172.23.255.255 scope global br-9d8122a452e5
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe56:267/64 scope link 
       valid_lft forever preferred_lft forever
158: veth275564d@if157: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-1a05d2c88bec state UP group default 
    link/ether 62:2e:2d:dc:35:ae brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::602e:2dff:fedc:35ae/64 scope link 
       valid_lft forever preferred_lft forever
160: veth69c5cf7@if159: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-1a05d2c88bec state UP group default 
    link/ether be:7a:1f:1c:7b:13 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::bc7a:1fff:fe1c:7b13/64 scope link 
       valid_lft forever preferred_lft forever
162: veth70a7df4@if161: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-1a05d2c88bec state UP group default 
    link/ether 46:54:98:b8:a8:69 brd ff:ff:ff:ff:ff:ff link-netnsid 2
    inet6 fe80::4454:98ff:feb8:a869/64 scope link 
       valid_lft forever preferred_lft forever
[kamran@kworkhorse compose]$ 
```
