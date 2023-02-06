#!/bin/bash

# Task 1

cat >> /etc/sysconfig/watchlog << EOF
# Configuration file for my watchlog service
# Place it to /etc/sysconfig

# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log
EOF

cat >> /var/log/watchlog.log << EOF
# Just a sample log

[    2.299768] ACPI: Video Device [GFX0] (multi-head: yes  rom: no  post: no)
[    2.300400] input: Video Bus as /devices/LNXSYSTM:00/device:00/PNP0A03:00/LNXVIDEO:00/input/input4
[    2.310241] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[    2.310833] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    2.340919] input: PC Speaker as /devices/platform/pcspkr/input/input5
[    2.350323] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    ALERT ] cryptd: max_cpu_qlen set to 1000
[    2.420856] AVX2 version of gcm_enc/dec engaged.
[    2.421361] AES CTR mode by8 optimization enabled
[    2.461215] ppdev: user-space parallel port driver
EOF

cat >> /opt/watchlog.sh << EOF
#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
logger "$DATE: I found word, Master!"
else
exit 0
fi
EOF

chmod +x /opt/watchlog.sh

cat >> /etc/systemd/system/watchlog.service << EOF
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
EOF

cat >> /etc/systemd/system/watchlog.timer << EOF
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target
EOF

systemctl start watchlog.timer

# Task 2

yum install -y epel-release
yum install -y spawn-fcgi php php-cli mod_fcgid httpd

sed -i 's/\#SOCKET=\/var\/run\/php-fcgi.sock/SOCKET=\/var\/run\/php-fcgi.sock/' /etc/sysconfig/spawn-fcgi
sed -i 's/\#OPTIONS=\"-u apache -g apache -s \$SOCKET -S -M 0600 -C 32 -F 1 -P \/var\/run\/spawn-fcgi.pid -- \/usr\/bin\/php-cgi\"/OPTIONS=\"-u apache -g apache -s \$SOCKET -S -M 0600 -C 32 -F 1 -- \/usr\/bin\/php-cgi\"/' /etc/sysconfig/spawn-fcgi

cat >> /etc/systemd/system/spawn-fcgi.service << EOF
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

systemctl start spawn-fcgi

# Task 3

yum install -y httpd

sed -i '/Listen 80/d' /etc/httpd/conf/httpd.conf

cat >> /etc/systemd/system/httpd@.service << EOF
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/%I
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
ExecStop=/bin/kill -WINCH ${MAINPID}
KillSignal=SIGCONT
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

echo -e 'Listen '"$"'{PORT}'"\n"'PidFile' "$"'{PID_FILE}' > /etc/httpd/conf.d/template.conf

cat >> /etc/sysconfig/httpd1 << EOF
PORT=81
PID_FILE=/etc/httpd/run/httpd1.pid
EOF

cat >> /etc/sysconfig/httpd2 << EOF
PORT=8008
PID_FILE=/etc/httpd/run/httpd2.pid
EOF

systemctl enable --now httpd@httpd1.service
systemctl enable --now httpd@httpd2.service
