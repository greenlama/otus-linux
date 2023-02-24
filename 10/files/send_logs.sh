#!/bin/bash

source /vagrant/config.ini

export $(cut -d= -f1 /vagrant/config.ini)

/vagrant/files/only_run.sh /vagrant/files/parse_logs.sh

# В случае, если установлен и настроен почтовый клиент, можно добавить пайп для отправки отчета на почту.
# /vagrant/files/only_run.sh /vagrant/files/parse_logs.sh | mail -s "Logs report" "$MAILTO"
