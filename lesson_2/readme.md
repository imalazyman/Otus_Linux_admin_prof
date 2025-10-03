<!-- ============= HOMEWORK-2 ============= -->


<!-- ===== просмотр сведений о дисках ===== -->

debugger@ubuntu-learn:~$ sudo lshw -short | grep disk
/0/5/0.0.0    /dev/cdrom  disk        CD-ROM
/0/6/0.0.0    /dev/sda    disk        21GB VBOX HARDDISK
/0/7/0.0.0    /dev/sdb    disk        1073MB HARDDISK
/0/7/0.1.0    /dev/sdc    disk        1073MB HARDDISK
/0/7/0.2.0    /dev/sdd    disk        1073MB HARDDISK
/0/7/0.3.0    /dev/sde    disk        1073MB HARDDISK
/0/7/0.4.0    /dev/sdf    disk        1073MB HARDDISK
debugger@ubuntu-learn:~$
debugger@ubuntu-learn:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0                       7:0    0 63,3M  1 loop /snap/core20/1828
loop2                       7:2    0 44,5M  1 loop /snap/snapd/23771
loop3                       7:3    0 49,9M  1 loop /snap/snapd/18357
loop4                       7:4    0 91,9M  1 loop /snap/lxd/29619
loop5                       7:5    0 63,8M  1 loop /snap/core20/2496
loop6                       7:6    0 91,9M  1 loop /snap/lxd/32662
sda                         8:0    0   20G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1,8G  0 part /boot
└─sda3                      8:3    0 18,2G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0   10G  0 lvm  /
sdb                         8:16   0    1G  0 disk
sdc                         8:32   0    1G  0 disk
sdd                         8:48   0    1G  0 disk
sde                         8:64   0    1G  0 disk
sdf                         8:80   0    1G  0 disk
sr0                        11:0    1 1024M  0 rom
debugger@ubuntu-learn:~$
debugger@ubuntu-learn:~$ sudo fdisk -l
Disk /dev/loop0: 63,29 MiB, 66359296 bytes, 129608 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/loop2: 44,46 MiB, 46604288 bytes, 91024 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/loop3: 49,86 MiB, 52260864 bytes, 102072 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/loop4: 91,9 MiB, 96346112 bytes, 188176 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/loop5: 63,76 MiB, 66842624 bytes, 130552 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/loop6: 91,91 MiB, 96354304 bytes, 188192 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 47BFB447-FA2F-41F3-BFE0-64EAC233628C

Device       Start      End  Sectors  Size Type
/dev/sda1     2048     4095     2048    1M BIOS boot
/dev/sda2     4096  3719167  3715072  1,8G Linux filesystem
/dev/sda3  3719168 41940991 38221824 18,2G Linux filesystem


Disk /dev/sdb: 1 GiB, 1073741824 bytes, 2097152 sectors
Disk model: HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdc: 1 GiB, 1073741824 bytes, 2097152 sectors
Disk model: HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdd: 1 GiB, 1073741824 bytes, 2097152 sectors
Disk model: HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sde: 1 GiB, 1073741824 bytes, 2097152 sectors
Disk model: HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdf: 1 GiB, 1073741824 bytes, 2097152 sectors
Disk model: HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/ubuntu--vg-ubuntu--lv: 10 GiB, 10737418240 bytes, 20971520 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
debugger@ubuntu-learn:~$
debugger@ubuntu-learn:~$ lsscsi
[1:0:0:0]    cd/dvd  VBOX     CD-ROM           1.0   /dev/sr0
[2:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sda
[3:0:0:0]    disk    VBOX     HARDDISK         1.0   /dev/sdb
[3:0:1:0]    disk    VBOX     HARDDISK         1.0   /dev/sdc
[3:0:2:0]    disk    VBOX     HARDDISK         1.0   /dev/sdd
[3:0:3:0]    disk    VBOX     HARDDISK         1.0   /dev/sde
[3:0:4:0]    disk    VBOX     HARDDISK         1.0   /dev/sdf


<!-- ============= Cборка RAID 6 ============= -->

debugger@ubuntu-learn:~$
debugger@ubuntu-learn:~$ mdadm --create --verbose /dev/md127 -l 6 -n 5
mdadm: must be super-user to perform this action
debugger@ubuntu-learn:~$ sudo mdadm --create --verbose /dev/md127 -l 6 -n 5
mdadm: You haven't given enough devices (real or missing) to create this array
debugger@ubuntu-learn:~$ sudo mdadm --create --verbose /dev/md127 -l 6 -n 5 /dev/sd{b,c,d,e,f}
mdadm: layout defaults to left-symmetric
mdadm: layout defaults to left-symmetric
mdadm: chunk size defaults to 512K
mdadm: size set to 1046528K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md127 started.
debugger@ubuntu-learn:~$
debugger@ubuntu-learn:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0 63,3M  1 loop  /snap/core20/1828
loop2                       7:2    0 44,5M  1 loop  /snap/snapd/23771
loop3                       7:3    0 49,9M  1 loop  /snap/snapd/18357
loop4                       7:4    0 91,9M  1 loop  /snap/lxd/29619
loop5                       7:5    0 63,8M  1 loop  /snap/core20/2496
loop6                       7:6    0 91,9M  1 loop  /snap/lxd/32662
sda                         8:0    0   20G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1,8G  0 part  /boot
└─sda3                      8:3    0 18,2G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0   10G  0 lvm   /
sdb                         8:16   0    1G  0 disk
└─md127                     9:127  0    3G  0 raid6
sdc                         8:32   0    1G  0 disk
└─md127                     9:127  0    3G  0 raid6
sdd                         8:48   0    1G  0 disk
└─md127                     9:127  0    3G  0 raid6
sde                         8:64   0    1G  0 disk
└─md127                     9:127  0    3G  0 raid6
sdf                         8:80   0    1G  0 disk
└─md127                     9:127  0    3G  0 raid6
sr0                        11:0    1 1024M  0 rom

<!-- ============= просмотр состояния ============= -->
debugger@ubuntu-learn:~$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [linear] [multipath] [raid0] [raid1] [raid10]
md127 : active raid6 sdf[4] sde[3] sdd[2] sdc[1] sdb[0]
      3139584 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]

unused devices: <none>
debugger@ubuntu-learn:~$ mdadm -D /dev/md127
mdadm: must be super-user to perform this action
debugger@ubuntu-learn:~$ sudo mdadm -D /dev/md127
/dev/md127:
           Version : 1.2
     Creation Time : Wed Mar 12 10:27:23 2025
        Raid Level : raid6
        Array Size : 3139584 (2.99 GiB 3.21 GB)
     Used Dev Size : 1046528 (1022.00 MiB 1071.64 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Wed Mar 12 10:27:32 2025
             State : clean
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : ubuntu-learn:127  (local to host ubuntu-learn)
              UUID : 39d45ace:ac65f670:2652957f:1b54b5b1
            Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       4       8       80        4      active sync   /dev/sdf
debugger@ubuntu-learn:~$

<!-- ============= "поломка"RAID ============= -->
debugger@ubuntu-learn:~$
debugger@ubuntu-learn:~$ sudo mdadm /dev/md127 --fail /dev/sdc
mdadm: set /dev/sdc faulty in /dev/md127
debugger@ubuntu-learn:~$
debugger@ubuntu-learn:~$ sudo cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [linear] [multipath] [raid0] [raid1] [raid10]
md127 : active raid6 sdf[4] sde[3] sdd[2] sdc[1](F) sdb[0]
      3139584 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/4] [U_UUU]

unused devices: <none>
debugger@ubuntu-learn:~$
debugger@ubuntu-learn:~$ sudo mdadm -D /dev/md127
/dev/md127:
           Version : 1.2
     Creation Time : Wed Mar 12 10:27:23 2025
        Raid Level : raid6
        Array Size : 3139584 (2.99 GiB 3.21 GB)
     Used Dev Size : 1046528 (1022.00 MiB 1071.64 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Wed Mar 12 10:35:58 2025
             State : clean, degraded
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 1
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : ubuntu-learn:127  (local to host ubuntu-learn)
              UUID : 39d45ace:ac65f670:2652957f:1b54b5b1
            Events : 19

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       -       0        0        1      removed
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       4       8       80        4      active sync   /dev/sdf

       1       8       32        -      faulty   /dev/sdc
debugger@ubuntu-learn:~$

<!-- ============= "починка"RAID ============= -->
debugger@ubuntu-learn:~$ sudo mdadm /dev/md127 --remove /dev/sdc
mdadm: hot removed /dev/sdc from /dev/md127
debugger@ubuntu-learn:~$ sudo mdadm --zero-superblock /dev/sdc
debugger@ubuntu-learn:~$ sudo mdadm /dev/md127 --add /dev/sdc
mdadm: added /dev/sdc
debugger@ubuntu-learn:~$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [linear] [multipath] [raid0] [raid1] [raid10]
md127 : active raid6 sdc[5] sdf[4] sde[3] sdd[2] sdb[0]
      3139584 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/4] [U_UUU]
      [================>....]  recovery = 81.0% (848444/1046528) finish=0.0min speed=212111K/sec

unused devices: <none>
debugger@ubuntu-learn:~$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [linear] [multipath] [raid0] [raid1] [raid10]
md127 : active raid6 sdc[5] sdf[4] sde[3] sdd[2] sdb[0]
      3139584 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]

unused devices: <none>

<!-- ============= разметка RAID ============= -->
debugger@ubuntu-learn:~$
debugger@ubuntu-learn:~$ parted -s /dev/md0 mklabel gpt
Error: Could not stat device /dev/md0 - No such file or directory.
debugger@ubuntu-learn:~$
debugger@ubuntu-learn:~$ parted -s /dev/md127 mklabel gpt-data
Error: Error opening /dev/md127: Permission denied
debugger@ubuntu-learn:~$ sudo parted -s /dev/md127 mklabel gpt-data
parted: invalid token: gpt-data
Error: Expecting a disk label type.
debugger@ubuntu-learn:~$ sudo parted -s /dev/md127 mklabel gptdata
parted: invalid token: gptdata
Error: Expecting a disk label type.
debugger@ubuntu-learn:~$ sudo parted -s /dev/md127 mklabel gpt
debugger@ubuntu-learn:~$ sudo parted /dev/md127 mkpart primary ext4 0% 20%
Information: You may need to update /etc/fstab.

debugger@ubuntu-learn:~$ sudo parted /dev/md127 mkpart primary ext4 20% 40%
Information: You may need to update /etc/fstab.

debugger@ubuntu-learn:~$ sudo parted /dev/md127 mkpart primary ext4 40% 60%
Information: You may need to update /etc/fstab.

debugger@ubuntu-learn:~$ sudo parted /dev/md127 mkpart primary ext4 60% 80%
Information: You may need to update /etc/fstab.

debugger@ubuntu-learn:~$ sudo parted /dev/md127 mkpart primary ext4 80% 100%
Information: You may need to update /etc/fstab.

<!-- ===== создание ФС на разделах RAID ====== -->
debugger@ubuntu-learn:~$
debugger@ubuntu-learn:~$ for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md127p$i; done
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 156672 4k blocks and 39200 inodes
Filesystem UUID: f1b99c8d-9f2a-4428-9c61-07a4e235133c
Superblock backups stored on blocks:
        32768, 98304

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 157056 4k blocks and 39280 inodes
Filesystem UUID: e6cbc46b-1a5c-4769-9a0f-531cea95e80c
Superblock backups stored on blocks:
        32768, 98304

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 156672 4k blocks and 39200 inodes
Filesystem UUID: 60a0303c-e401-4593-bcb7-294418aa111a
Superblock backups stored on blocks:
        32768, 98304

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 157056 4k blocks and 39280 inodes
Filesystem UUID: 971014a1-7325-4b2b-a7fe-39733a89f94b
Superblock backups stored on blocks:
        32768, 98304

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 156672 4k blocks and 39200 inodes
Filesystem UUID: e08ee783-914a-4ad0-9ff3-de688fa2a217
Superblock backups stored on blocks:
        32768, 98304

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done


<!-- ==== монтирование разделов в каталоги === -->
debugger@ubuntu-learn:~$ sudo mkdir -p /mnt/volume{1,2,3,4,5}
debugger@ubuntu-learn:~$ ls /mnt/
volume1  volume2  volume3  volume4  volume5
debugger@ubuntu-learn:~$
debugger@ubuntu-learn:~$ for i in $(seq 1 5); do sudo mount /dev/md127p$i /mnt/volume$i; done
debugger@ubuntu-learn:~$



<!-- ============= Разборка RAID ============= -->
debugger@ubuntu-learn:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0 63,3M  1 loop  /snap/core20/1828
loop2                       7:2    0 44,5M  1 loop  /snap/snapd/23771
loop3                       7:3    0 49,9M  1 loop  /snap/snapd/18357
loop4                       7:4    0 91,9M  1 loop  /snap/lxd/29619
loop5                       7:5    0 63,8M  1 loop  /snap/core20/2496
loop6                       7:6    0 91,9M  1 loop  /snap/lxd/32662
sda                         8:0    0   20G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1,8G  0 part  /boot
└─sda3                      8:3    0 18,2G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0   10G  0 lvm   /
sdb                         8:16   0    1G  0 disk
└─md127                     9:127  0    3G  0 raid6
sdc                         8:32   0    1G  0 disk
└─md127                     9:127  0    3G  0 raid6
sdd                         8:48   0    1G  0 disk
└─md127                     9:127  0    3G  0 raid6
sde                         8:64   0    1G  0 disk
└─md127                     9:127  0    3G  0 raid6
sdf                         8:80   0    1G  0 disk
└─md127                     9:127  0    3G  0 raid6
sr0                        11:0    1 1024M  0 rom
debugger@ubuntu-learn:~$ sudo mdadm -S /dev/md127
[sudo] password for debugger:
mdadm: stopped /dev/md127
debugger@ubuntu-learn:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0                       7:0    0 63,3M  1 loop /snap/core20/1828
loop2                       7:2    0 44,5M  1 loop /snap/snapd/23771
loop3                       7:3    0 49,9M  1 loop /snap/snapd/18357
loop4                       7:4    0 91,9M  1 loop /snap/lxd/29619
loop5                       7:5    0 63,8M  1 loop /snap/core20/2496
loop6                       7:6    0 91,9M  1 loop /snap/lxd/32662
sda                         8:0    0   20G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1,8G  0 part /boot
└─sda3                      8:3    0 18,2G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0   10G  0 lvm  /
sdb                         8:16   0    1G  0 disk
sdc                         8:32   0    1G  0 disk
sdd                         8:48   0    1G  0 disk
sde                         8:64   0    1G  0 disk
sdf                         8:80   0    1G  0 disk
sr0                        11:0    1 1024M  0 rom
debugger@ubuntu-learn:~$ sudo mdadm --zero-superblock /dev/sd{b,c,d,e,f}
debugger@ubuntu-learn:~$

