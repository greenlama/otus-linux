# Lesson 17

## Цель домашнего задания

Диагностировать проблемы и модифицировать политики SELinux для корректной работы приложений, если это требуется.

## Описание домашнего задания

1. Запустить nginx на нестандартном порту 3-мя разными способами:
- переключатели setsebool;
- добавление нестандартного порта в имеющийся тип;
- формирование и установка модуля SELinux.

К сдаче:
- README с описанием каждого решения (скриншоты и демонстрация приветствуются). 

2. Обеспечить работоспособность приложения при включенном selinux.
- развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems; 
- выяснить причину неработоспособности механизма обновления зоны (см. README);
- предложить решение (или решения) для данной проблемы;
- выбрать одно из решений для реализации, предварительно обосновав выбор;
- реализовать выбранное решение и продемонстрировать его работоспособность.

## Запустить nginx на нестандартном порту 3-мя разными способами

### Переключатели setsebool

```
[root@selinux vagrant]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)
[root@selinux vagrant]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
[root@selinux vagrant]# getenforce
Enforcing
[root@selinux vagrant]# audit2why < /var/log/audit/audit.log
type=AVC msg=audit(1679228327.198:843): avc:  denied  { name_bind } for  pid=2901 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

        Was caused by:
        The boolean nis_enabled was set incorrectly. 
        Description:
        Allow nis to enabled

        Allow access by executing:
        # setsebool -P nis_enabled 1
[root@selinux vagrant]# setsebool -P nis_enabled 1
[root@selinux vagrant]# systemctl restart nginx
[root@selinux vagrant]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2023-03-19 12:43:00 UTC; 6s ago
  Process: 3306 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3304 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 3303 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3308 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3308 nginx: master process /usr/sbin/nginx
           └─3310 nginx: worker process

Mar 19 12:43:00 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Mar 19 12:43:00 selinux nginx[3304]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Mar 19 12:43:00 selinux nginx[3304]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Mar 19 12:43:00 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
[root@selinux vagrant]# getsebool -a | grep nis_enabled
nis_enabled --> on
```

### Добавление нестандартного порта в имеющийся тип

```
[root@selinux vagrant]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
[root@selinux vagrant]# semanage port -a -t http_port_t -p tcp 4881
[root@selinux vagrant]# systemctl restart nginx
[root@selinux vagrant]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2023-03-19 12:46:11 UTC; 6s ago
  Process: 3342 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3339 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 3338 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3344 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3344 nginx: master process /usr/sbin/nginx
           └─3345 nginx: worker process

Mar 19 12:46:11 selinux systemd[1]: Stopped The nginx HTTP and reverse proxy server.
Mar 19 12:46:11 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Mar 19 12:46:11 selinux nginx[3339]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Mar 19 12:46:11 selinux nginx[3339]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Mar 19 12:46:11 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
```

### Формирование и установка модуля SELinux

```
[root@selinux vagrant]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i nginx.pp
[root@selinux vagrant]# semodule -i nginx.pp
[root@selinux vagrant]# systemctl start nginx
[root@selinux vagrant]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2023-03-19 12:49:56 UTC; 6s ago
  Process: 3403 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3401 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 3400 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3405 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3405 nginx: master process /usr/sbin/nginx
           └─3406 nginx: worker process

Mar 19 12:49:56 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Mar 19 12:49:56 selinux nginx[3401]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Mar 19 12:49:56 selinux nginx[3401]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Mar 19 12:49:56 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
```

## Обеспечить работоспособность приложения при включенном selinux

```
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> 
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
update failed: SERVFAIL
> quit
cat /var/log/audit/audit.log | audit2why
[root@ns01 ~]# cat /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1679231169.800:1931): avc:  denied  { create } for  pid=5198 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

        Was caused by:
                Missing type enforcement (TE) allow rule.

                You can use audit2allow to generate a loadable module to allow this access.

[root@ns01 ~]# ls -laZ /etc/named
drw-rwx---. root named system_u:object_r:etc_t:s0       .
drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
drw-rwx---. root named unconfined_u:object_r:etc_t:s0   dynamic
-rw-rw----. root named system_u:object_r:etc_t:s0       named.50.168.192.rev
-rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab
-rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab.view1
-rw-rw----. root named system_u:object_r:etc_t:s0       named.newdns.lab
```
Ошибка в контексте безопасности. Вместо типа named_t используется тип etc_t. Проблема заключается в том, что конфигурационные файлы лежат в другом каталоге.
```
[root@ns01 ~]# sudo semanage fcontext -l | grep named
/etc/rndc.*                                        regular file       system_u:object_r:named_conf_t:s0 
/var/named(/.*)?                                   all files          system_u:object_r:named_zone_t:s0 
/etc/unbound(/.*)?                                 all files          system_u:object_r:named_conf_t:s0 
/var/run/bind(/.*)?                                all files          system_u:object_r:named_var_run_t:s0 
/var/log/named.*                                   regular file       system_u:object_r:named_log_t:s0
...
```
Решением может быть простое и эффективное выполнение команды, которая помогает изменить контекст SELinux или TYPE.
```
[root@ns01 ~]# sudo chcon -R -t named_zone_t /etc/named
[root@ns01 ~]# ls -laZ /etc/named
drw-rwx---. root named system_u:object_r:named_zone_t:s0 .
drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
drw-rwx---. root named unconfined_u:object_r:named_zone_t:s0 dynamic
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.50.168.192.rev
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab.view1
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.newdns.lab
```
```
[root@client ~]# nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add > incorrect section name: >
> www.ddns.lab. 60 A 192.168.50.15
> send
> quit
[root@client ~]# dig www.ddns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.13 <<>> www.ddns.lab
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 10044
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.ddns.lab.                  IN      A

;; AUTHORITY SECTION:
ddns.lab.               600     IN      SOA     ns01.dns.lab. root.dns.lab. 2711201407 3600 600 86400 600

;; Query time: 12 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Sun Mar 19 13:14:34 UTC 2023
;; MSG SIZE  rcvd: 91
```
