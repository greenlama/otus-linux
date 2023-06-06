# Lesson 33

## Задание

в Office1 в тестовой подсети появляется сервера с доп интерфесами и адресамив internal сети testLAN

- testClient1 - 10.10.10.254
- testClient2 - 10.10.10.254
- testServer1- 10.10.10.1
- testServer2- 10.10.10.1
развести вланами
testClient1 <-> testServer1
testClient2 <-> testServer2
между centralRouter и inetRouter
"пробросить" 2 линка (общая inernal сеть) и объединить их в бонд

## Проверка с отключением интерфейса

После настройки агрегации портов, необходимо проверить работу bond-интерфейса, для этого, на хосте inetRouter (192.168.255.1) запустим ping до centralRouter (192.168.255.2). Не отменяя ping подключаемся к хосту centralRouter и выключаем там интерфейс eth1. После данного действия ping не пропал, так как трафик пошел по другому порту.

```
[vagrant@inetRouter ~]$ ping 192.168.1.2	
PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.	
64 bytes from 192.168.1.2: icmp_seq=1 ttl=64 time=0.907 ms	
64 bytes from 192.168.1.2: icmp_seq=2 ttl=64 time=0.643 ms	
64 bytes from 192.168.1.2: icmp_seq=3 ttl=64 time=1.82 ms
64 bytes from 192.168.1.2: icmp_seq=4 ttl=64 time=0.821 ms
64 bytes from 192.168.1.2: icmp_seq=5 ttl=64 time=0.764 ms
64 bytes from 192.168.1.2: icmp_seq=6 ttl=64 time=1.83 ms
64 bytes from 192.168.1.2: icmp_seq=7 ttl=64 time=0.803 ms
64 bytes from 192.168.1.2: icmp_seq=8 ttl=64 time=0.675 ms
64 bytes from 192.168.1.2: icmp_seq=9 ttl=64 time=0.738 ms
64 bytes from 192.168.1.2: icmp_seq=10 ttl=64 time=0.714 ms
64 bytes from 192.168.1.2: icmp_seq=11 ttl=64 time=0.869 ms
64 bytes from 192.168.1.2: icmp_seq=12 ttl=64 time=1.56 ms
64 bytes from 192.168.1.2: icmp_seq=13 ttl=64 time=0.708 ms
```
