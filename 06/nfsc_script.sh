#!/bin/bash

yum install nfs-utils -y

systemctl enable firewalld --now 
systemctl status firewalld

echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,timeo=900,retrans=5,_netdev,noauto,x-systemd.automount,x-systemd.mount-temeout=10,timeo=14,x-systemd.idle-timeout=1min 0 0" >> /etc/fstab

systemctl daemon-reload 
systemctl restart remote-fs.target
