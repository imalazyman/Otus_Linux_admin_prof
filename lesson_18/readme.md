# Домашнее задание №18 по теме Vagrant

### Задание: Обновить ядро в базовой системе.

Приложен Vagrantfile
На выходе получаем виртуалку Centos8 c обновленным ядром 6.16

    $ vagrant ssh
    [vagrant@kern-up-test ~]$ uname -r
    6.16.3-1.el8.elrepo.x86_64
