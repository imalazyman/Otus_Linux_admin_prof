<!-- ============= HOMEWORK-4 ============= -->

root@ubuntu-learn:/# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0    1G  0 disk
sdb                         8:16   0    1G  0 disk
sdc                         8:32   0    1G  0 disk
sdd                         8:48   0    1G  0 disk
sde                         8:64   0    1G  0 disk
sdf                         8:80   0    1G  0 disk
sdg                         8:96   0    1G  0 disk
sdh                         8:112  0    1G  0 disk
sdi                         8:128  0   20G  0 disk
├─sdi1                      8:129  0    1M  0 part
├─sdi2                      8:130  0  1,8G  0 part /boot
└─sdi3                      8:131  0 18,2G  0 part
  └─ubuntu--vg-ubuntu--lv 252:1    0    8G  0 lvm  /
sdj                         8:144  0   10G  0 disk
sr0                        11:0    1 1024M  0 rom
root@ubuntu-learn:/#
root@ubuntu-learn:/#  apt install zfsutils-linux
Installing:
  zfsutils-linux
......
Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
root@ubuntu-learn:/home#
root@ubuntu-learn:/# zpool create zfs-test1 mirror /dev/sda /dev/sdb
root@ubuntu-learn:/# zpool create zfs-test2 mirror /dev/sdc /dev/sdd
root@ubuntu-learn:/# zpool create zfs-test3 mirror /dev/sde /dev/sdf
root@ubuntu-learn:/# zpool create zfs-test4 mirror /dev/sdg /dev/sdh
root@ubuntu-learn:/# zfs set compression=lzjb zfs-test1
root@ubuntu-learn:/# zfs set compression=lz4 zfs-test2
root@ubuntu-learn:/# zfs set compression=gzip-9 zfs-test3
root@ubuntu-learn:/# zfs set compression=zle zfs-test4

root@ubuntu-learn:/# for i in {1..4}; do wget -P /zfs-test$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
root@ubuntu-learn:/home# ls -l /zfs-test*
/zfs-test1:
total 22098
-rw-rw-r-- 1 root root 41130189 мар  2 08:31 pg2600.converter.log

/zfs-test2:
total 18008
-rw-rw-r-- 1 root root 41130189 мар  2 08:31 pg2600.converter.log

/zfs-test3:
total 10967
-rw-rw-r-- 1 root root 41130189 мар  2 08:31 pg2600.converter.log

/zfs-test4:
total 40196
-rw-rw-r-- 1 root root 41130189 мар  2 08:31 pg2600.converter.log
root@ubuntu-learn:/#
root@ubuntu-learn:/# zfs list
NAME        USED  AVAIL  REFER  MOUNTPOINT
zfs-test1  21.7M   810M  21.6M  /zfs-test1
zfs-test2  17.7M   814M  17.6M  /zfs-test2
zfs-test3  10.9M   821M  10.7M  /zfs-test3
zfs-test4  39.4M   793M  39.3M  /zfs-test4
root@ubuntu-learn:/# zfs get all | grep compressratio | grep -v ref
zfs-test1  compressratio         1.81x                      -
zfs-test2  compressratio         2.23x                      -
zfs-test3  compressratio         3.65x                      -
zfs-test4  compressratio         1.00x                      -
root@ubuntu-learn:/#
wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'
root@ubuntu-learn:~# ls
archive.tar.gz
root@ubuntu-learn:~# tar -xzvf archive.tar.gz
zpoolexport/
zpoolexport/filea
zpoolexport/fileb
root@ubuntu-learn:~# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
status: Some supported features are not enabled on the pool.
	(Note that they may be intentionally disabled if the
	'compatibility' property is set.)
 action: The pool can be imported using its name or numeric identifier, though
	some features will not be available without an explicit 'zpool upgrade'.
 config:

	otus                         ONLINE
	  mirror-0                   ONLINE
	    /root/zpoolexport/filea  ONLINE
	    /root/zpoolexport/fileb  ONLINE
root@ubuntu-learn:~# zpool import -d zpoolexport/ otus
root@ubuntu-learn:~# zpool list
NAME        SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus        480M  2.18M   478M        -         -     0%     0%  1.00x    ONLINE  -
zfs-test1   960M  21.7M   938M        -         -     0%     2%  1.00x    ONLINE  -
zfs-test2   960M  17.7M   942M        -         -     0%     1%  1.00x    ONLINE  -
zfs-test3   960M  10.9M   949M        -         -     0%     1%  1.00x    ONLINE  -
zfs-test4   960M  39.4M   921M        -         -     0%     4%  1.00x    ONLINE  -
root@ubuntu-learn:~# zpool status


<!-- Размер:  -->
root@ubuntu-learn:/# zfs get available otus
NAME  PROPERTY   VALUE  SOURCE
otus  available  350M   -
<!-- Тип:  -->
root@ubuntu-learn:/# zfs get readonly otus
NAME  PROPERTY  VALUE   SOURCE
otus  readonly  off     default
<!-- Значение recordsize:  -->
root@ubuntu-learn:/# zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local
<!-- Тип сжатия:  -->
root@ubuntu-learn:/# zfs get compression otus
NAME  PROPERTY     VALUE           SOURCE
otus  compression  zle             local
<!-- Тип контрольной суммы:  -->
root@ubuntu-learn:/# zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local
<!-- Точка монтирования -->
root@ubuntu-learn:/# zfs get mountpoint otus
NAME  PROPERTY    VALUE       SOURCE
otus  mountpoint  /otus       default
<!-- Наличие и количеcтво снапшотов  -->
root@ubuntu-learn:/# zfs get snapshot_count otus
NAME  PROPERTY        VALUE    SOURCE
otus  snapshot_count  none     default
<!-- Установленая квота -->
root@ubuntu-learn:/# zfs get quota otus
NAME  PROPERTY  VALUE  SOURCE
otus  quota     none   default

root@ubuntu-learn:~# wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download

root@ubuntu-learn:~# ls
archive.tar.gz  boot.log  otus_task2.file  wget-log  zpoolexport
root@ubuntu-learn:~# zfs receive otus/test@today < otus_task2.file
root@ubuntu-learn:/# find /otus/test/task1/file_mess/secret_message
/otus/test/task1/file_mess/secret_message
root@ubuntu-learn:/#
root@ubuntu-learn:/# cat /otus/test/task1/file_mess/secret_message
https://otus.ru/lessons/linux-hl/

root@ubuntu-learn:/#