# Домашнее задание 5

## Настройка сервера

    debugger@ubuntu-learn:~$ neofetch
                .-/+oossssoo+/-.               debugger@ubuntu-learn
            `:+ssssssssssssssssss+:`           ---------------------
          -+ssssssssssssssssssyyssss+-         OS: Ubuntu 24.10 x86_64
        .ossssssssssssssssssdMMMNysssso.       Host: VirtualBox 1.2
      /ssssssssssshdmmNNmmyNMMMMhssssss/      Kernel: 6.11.0-21-generic
      +ssssssssshmydMMMMMMMNddddyssssssss+     Uptime: 16 hours, 46 mins
    /sssssssshNMMMyhhyyyyhmNMMMNhssssssss/    Packages: 819 (dpkg)
    .ssssssssdMMMNhsssssssssshNMMMdssssssss.   Shell: bash 5.2.32
    +sssshhhyNMMNyssssssssssssyNMMMysssssss+   Resolution: 1280x800
    ossyNMMMNyMMhsssssssssssssshmmmhssssssso   Terminal: /dev/pts/0
    ossyNMMMNyMMhsssssssssssssshmmmhssssssso   CPU: Intel i7-8700 (2) @ 3.192GHz
    +sssshhhyNMMNyssssssssssssyNMMMysssssss+   GPU: 00:02.0 VMware SVGA II Adapter
    .ssssssssdMMMNhsssssssssshNMMMdssssssss.   Memory: 254MiB / 1647MiB
    /sssssssshNMMMyhhyyyyhdNMMMNhssssssss/
      +sssssssssdmydMMMMMMMMddddyssssssss+
      /ssssssssssshdmNNNNmyNMMMMhssssss/
        .ossssssssssssssssssdMMMNysssso.
          -+sssssssssssssssssyyyssss+-
            `:+ssssssssssssssssss+:`
                .-/+oossssoo+/-.

    debugger@ubuntu-learn:~$
    debugger@ubuntu-learn:~$ su -
    Password:
  #### Просмотр блочных устройств
    root@ubuntu-learn:~# lsblk
    NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
    sda                         8:0    0   20G  0 disk
    ├─sda1                      8:1    0    1M  0 part
    ├─sda2                      8:2    0  1,8G  0 part /boot
    └─sda3                      8:3    0 18,2G  0 part
      └─ubuntu--vg-ubuntu--lv 252:0    0    8G  0 lvm  /
    sdb                         8:16   0    1G  0 disk
    ├─sdb1                      8:17   0 1014M  0 part
    └─sdb9                      8:25   0    8M  0 part
    sdc                         8:32   0    1G  0 disk
    ├─sdc1                      8:33   0 1014M  0 part
    └─sdc9                      8:41   0    8M  0 part
    sdd                         8:48   0    1G  0 disk
    ├─sdd1                      8:49   0 1014M  0 part
    └─sdd9                      8:57   0    8M  0 part
    sde                         8:64   0    1G  0 disk
    ├─sde1                      8:65   0 1014M  0 part
    └─sde9                      8:73   0    8M  0 part
    sdf                         8:80   0    1G  0 disk
    ├─sdf1                      8:81   0 1014M  0 part
    └─sdf9                      8:89   0    8M  0 part
    sdg                         8:96   0    1G  0 disk
    ├─sdg1                      8:97   0 1014M  0 part
    └─sdg9                      8:105  0    8M  0 part
    sdh                         8:112  0    1G  0 disk
    ├─sdh1                      8:113  0 1014M  0 part
    └─sdh9                      8:121  0    8M  0 part
    sdi                         8:128  0    1G  0 disk
    ├─sdi1                      8:129  0 1014M  0 part
    └─sdi9                      8:137  0    8M  0 part
    sdj                         8:144  0   10G  0 disk
    sr0                        11:0    1 1024M  0 rom
  #### Создание фаловой системы на устройстве SDJ
    root@ubuntu-learn:~# mkfs.ext4 /dev/sdj
    mke2fs 1.47.1 (20-May-2024)
    Creating filesystem with 2621440 4k blocks and 655360 inodes
    Filesystem UUID: 2e3f0e61-672a-41b8-9707-33d539ba7ee3
    Superblock backups stored on blocks:
            32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

    Allocating group tables: done
    Writing inode tables: done
    Creating journal (16384 blocks): done
    Writing superblocks and filesystem accounting information: done
  #### Монтирование диска в папку /data
    root@ubuntu-learn:~# mount /dev/sdj /data
    root@ubuntu-learn:~# lsblk
    NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
    .........
    sdj                         8:144  0   10G  0 disk /data
    .........

  #### Установка и просмотр кофигурации NFS-сервера
    root@ubuntu-learn:~# apt install nfs-kernel-server
    Уже установлен пакет nfs-kernel-server самой новой версии (1:2.6.4-4ubuntu1).
    Summary:
      Upgrading: 0, Installing: 0, Removing: 0, Not Upgrading: 0
    root@ubuntu-learn:~# cat /etc/nfs.conf
    #
    # This is a general configuration for the
    # NFS daemons and tools
    #
    [general]
    pipefs-directory=/run/rpc_pipefs
    #
    [nfsrahead]
    # nfs=15000
    # nfs4=16000
    #
    [exports]
    # rootdir=/export
    #
    [exportfs]
    # debug=0
    #
    [gssd]
    # verbosity=0
    # rpc-verbosity=0
    # use-memcache=0
    # use-machine-creds=1
    # use-gss-proxy=0
    # avoid-dns=1
    # limit-to-legacy-enctypes=0
    # context-timeout=0
    # rpc-timeout=5
    # keytab-file=/etc/krb5.keytab
    # cred-cache-directory=
    # preferred-realm=
    # set-home=1
    # upcall-timeout=30
    # cancel-timed-out-upcalls=0
    #
    [lockd]
    # port=0
    # udp-port=0
    #
    [exportd]
    # debug="all|auth|call|general|parse"
    # manage-gids=n
    # state-directory-path=/var/lib/nfs
    # threads=1
    # cache-use-ipaddr=n
    # ttl=1800
    [mountd]
    # debug="all|auth|call|general|parse"
    manage-gids=y
    # descriptors=0
    # port=0
    # threads=1
    # reverse-lookup=n
    # state-directory-path=/var/lib/nfs
    # ha-callout=
    # cache-use-ipaddr=n
    # ttl=1800
    #
    [nfsdcld]
    # debug=0
    # storagedir=/var/lib/nfs/nfsdcld
    #
    [nfsdcltrack]
    # debug=0
    # storagedir=/var/lib/nfs/nfsdcltrack
    #
    [nfsd]
    # debug=0
    # threads=8
    # host=
    # port=0
    # grace-time=90
    # lease-time=90
    # udp=n
    # tcp=y
    # vers3=y
    # vers4=y
    # vers4.0=y
    # vers4.1=y
    # vers4.2=y
    # rdma=n
    # rdma-port=20049

    [statd]
    # debug=0
    # port=0
    # outgoing-port=0
    # name=
    # state-directory-path=/var/lib/nfs/statd
    # ha-callout=
    # no-notify=0
    #
    [sm-notify]
    # debug=0
    # force=0
    # retry-time=900
    # outgoing-port=
    # outgoing-addr=
    # lift-grace=y
    #
    [svcgssd]
    # principal=

#### Создаем директорию для общего доступа, назначаем права и настраиваем общий доступ
    root@ubuntu-learn:~# mkdir -p /data/share/upload
    root@ubuntu-learn:~# chown -R nobody:nogroup /data/share/upload/
    root@ubuntu-learn:~# chmod 0777  /data/share/upload/
    root@ubuntu-learn:~# nano /etc/exports
    root@ubuntu-learn:~# cat /etc/exports
    # /etc/exports: the access control list for filesystems which may be exported
    #               to NFS clients.  See exports(5).
    #
    # Example for NFSv2 and NFSv3:
    # /srv/homes       hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check)
    #
    # Example for NFSv4:
    # /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
    # /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)
    #
    root@ubuntu-learn:~#  exportfs -r
    root@ubuntu-learn:~# exportfs -s
    /data/share/upload  *(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
    root@ubuntu-learn:~#


## Настройка клиента

    [debugger@redos-learn ~]$ neofetch
    "                                                     debugger@redos-learn
    "     =++++++++++++=  =++++++++++++=                  --------------------
    "     +############+  +############+                  OS: RED OS (8.0) x86_64
    "     +############+  +############+                  Host: VirtualBox 1.2
    "     +############+  +############+                  Kernel: 6.6.76-1.red80.x86_64
    "     +############+  +############+                  Uptime: 31 secs
    "     +############+  +############+                  Packages: 583 (rpm)
    "     =************=  =************=                  Shell: bash 5.2.15
    "                                                     Resolution: 1280x800
    "     =++++++++++++=                                  Terminal: /dev/pts/0
    "     +############+                                  CPU: Intel i7-8700 (2) @ 3.192GHz
    "     +############+                                  GPU: 00:02.0 VMware SVGA II Adapter
    "     +############+                                  Memory: 196MiB / 3917MiB
    "     +############+
    "     +############+
    "     =************=
    "

    [debugger@redos-learn ~]$ su -
    Пароль:
    [root@redos-learn ~]# dnf install nfs-utils
    [root@redos-learn ~]# showmount -e 10.4.136.162
    Export list for 10.4.136.162:
    /data/share/upload *

#### Ручное монтирование
    [root@redos-learn ~]# mount -t nfs 10.4.136.162:/data/share/upload /mnt/shares/
    [root@redos-learn ~]# mount | grep shares
    10.4.136.162:/data/share/upload on /mnt/shares type nfs4 (rw,relatime,vers=4.2,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.4.136.135,local_lock=none,addr=10.4.136.162)

#### Монтирование через fstab, версия NFS -3
    [root@redos-learn ~]# cat /etc/fstab
    .......
    UUID=69b200e2-3b07-4586-8e2b-c1473654cdf4 /                       ext4    defaults        1 1
    UUID=217f4919-1c0d-434b-80a3-9b021c0e0997 /boot                   ext4    defaults        1 2
    UUID=08e57764-0de6-4253-b582-e9f7ed95938a none                    swap    defaults        0 0
    10.4.136.162:/data/share/upload /mnt/shares  nfs  noauto,nofail,vers=3,x-systemd.automount,x-systemd.mount-timeout=10,_netdev          0  0
    [root@redos-learn ~]#
    [debugger@redos-learn ~]$ sudo reboot
    ........................
    [debugger@redos-learn ~]$ cd /mnt/shares/
    [debugger@redos-learn shares]$ ll
    итого 0
    -rw-rw-r--. 1 root root 0 апр  2 08:56 check_file
    [debugger@redos-learn shares]$ sudo mount | grep nfs
    [sudo] пароль для debugger:
    sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw,relatime)
    10.4.136.162:/data/share/upload on /mnt/shares type nfs (rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.4.136.162,mountvers=3,mountport=44765,mountproto=udp,local_lock=none,addr=10.4.136.162,_netdev)
    [debugger@redos-learn shares]$