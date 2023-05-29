#!/bin/bash
USAGE="SYNOPSIS: ./port_knocking.sh <TARGET_IP> <port_1> [<port_2> <port_3> ...]"
if [ -z "$1" ]
then
    echo "Sorry, there is no first parameter TARGET_IP. "
    echo $USAGE
    exit 1
fi

if [ -z "$2" ]
then
    echo "Sorry, some knock-port id needed. "
    echo $USAGE
    exit 1
fi

TARGET_IP=$1
shift
for ARG in "$@"
do
  sudo nmap -Pn --max-retries 0 -p $ARG $TARGET_IP
done