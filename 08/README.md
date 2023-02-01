# Lesson 08

## 1. Попасть в систему без пароля несколькими способами

### Способ 1. init=/bin/sh

В конце строки начинающейся с linux16 добавляем init=/bin/sh и нажимаем сtrl-x для загрузки в систему.
Попадаем в shell без пароля. Приветствие: sh-4.2#
Рутовая файловая система при этом монтируется в режиме Read-Only. Чтобы перемонтировать ее в режим Read-Write воспользуемся командой:
sh-4.2# mount -o remount,rw

Воспользуемся следующей командой и увидим результаты монтирования:

sh-4.2# mount | grep root

/dev/mapper/centos-root on /type xfs (rw,realtime,attr2,inode64,noquota)

### Способ 2. rd.break

В конце строки начинающейся с linux16 добавляем rd.break и нажимаем сtrl-x для загрузки в систему.
Попадаем в emergency mode. Файловая система смонтирована опять же в режиме Read-Only, но мы не в ней. Далее будет пример как попасть в нее и поменять пароль администратора:
Entering emergency mode. Exit the shell to continue.

Type "jornalctl" to view system logs.

You might want to save "/run/initframfs/rdsosreport.txt" to USB stick or /boot after mounting them and attach it to a bug report.

switch_root:/#

switch_root:/# mount -o remount,rw /sysroot

switch_root:/# chroot /sysroot

sh-4.2# passwd root

Changing password for user root.

New password:

BAD PASSWORD: The password is shorter than 7 characters

Retype new password:

passwd: all authentication token updated successfully.

sh-4.2# touch /.autorelabel

После перезагрузился и зашел под новым паролем:

localhost login: root

Password:

Last login: Wed Feb 01 23:27:48 on tty1

[root@localhost ~]#

### Способ 3. rw init=/sysroot/bin/sh

В строке начинающейся с linux16 заменяем ro на rw init=/sysroot/bin/sh и нажимаем сtrl-xдля загрузки в систему. От прошлого примера отличается только тем, что файловая система сразу смонтирована в режим Read-Write:

Entering emergency mode. Exit the shell to continue.

Type "jornalctl" to view system logs.

You might want to save "/run/initframfs/rdsosreport.txt" to USB stick or /boot after mounting them and attach it to a bug report.

:/#

## 2. Установить систему с LVM, после чего переименовать VG.

Вначале посмотрим текущее состояние системы:

[root@localhost ~]# vgs

VG #PV #LV #SN Attr VSize VFree

centos 1 2 0 wz--n- <7.00g 0

Интересует вторая строка с именем centos

Приступим к переименованию:

[root@localhost ~]# vgrename centos OtusRoot

Volume group "centos" successfully renamed to "OtusRoot"

Правим конфигурационные файлы:

[root@localhost ~]# sed -i 's/centos/otusroot/g' /boot/grub2/grub.cfg && sed -i 's/centos/otusroot/g' /etc/fstab

Пересоздаем initrd image, чтобы он знал новое название Volume Group*

[root@localhost ~]# mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)

...

*** Creating image file done ***

*** Creating initramfs image file '/boot/initramfs-3.10.0-862.el7.x86_64.img' done ***

Перезагружаемся и проверяем успешную загрузку с новым именем:

[root@localhost ~]# vgs

VG #PV #LV #SN Attr VSize VFree

OtusRoot 1 2 0 wz--n- <7.00g 0

## 3. Добавить модуль в initrd

Скрипты модулей хранятся в каталоге /usr/lib/dracut/modules.d/. Для того чтобы добавить свой модуль создаем там папку с именем 01test:

[root@localhost ~]# mkdir /usr/lib/dracut/modules.d/01test

В нее поместим два скрипта:

1.module-setup.sh - который устанавливает модуль и вызывает скрипт test.sh

2.test.sh - собственно сам вызываемый скрипт, в нём у нас рисуется пингвинчик.

Пересобираем образ initrd и видим пингвинчика :=)

[root@localhost ~]# mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)

[root@localhost ~]# dracut -f -v

Можно проверить/посмотреть какие модули загружены в образ:

[root@localhost ~]# lsinitrd -m /boot/initramfs-$(uname -r).img | grep test

test

Далее отредактируем grub.cfg убрав опции rghb и quiet:

... linux16 /vmlinuz-3.10.0-862.el7.x86_64 root=/dev/mapper/OtusRoot-root ro crashkernel=auto rd.lvm.lv=OtusRoot/root rd.lvm.lv=OtusRoot/swap LANG=eng_US.UTF-8

    initrd16 /initramfs-3.10.0-862.2.3.el7.x86_64.img
...

После перезагрузки и после паузы на 10 секунд появился пингвин в выводе терминала.
