<!-- ============= HOMEWORK-3 ============= -->


<!-- 1.	Уменьшить том под / до 8G.; -->

<!-- ===== просмотр сведений о дисках ===== -->

root@ubuntu-learn:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   20G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1,8G  0 part /boot
└─sda3                      8:3    0 18,2G  0 part
  └─ubuntu--vg-ubuntu--lv 252:0    0   10G  0 lvm  /
sdb                         8:16   0   10G  0 disk
sdc                         8:32   0    1G  0 disk
sdd                         8:48   0    1G  0 disk
sde                         8:64   0    1G  0 disk
sdf                         8:80   0    1G  0 disk
sdg                         8:96   0    1G  0 disk
sdh                         8:112  0    1G  0 disk
sr0                        11:0    1 1024M  0 rom
root@ubuntu-learn:~#

<!-- ============= Cоздаем LVM для переноса ============= -->

root@ubuntu-learn:~# pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
root@ubuntu-learn:~# vgcreate vg_root /dev/sdb
  Volume group "vg_root" successfully created
root@ubuntu-learn:~# lvcreate -n lv_root -l +100%FREE /dev/vg_root
WARNING: ext4 signature detected on /dev/vg_root/lv_root at offset 1080. Wipe it? [y/n]: y
  Wiping ext4 signature on /dev/vg_root/lv_root.
  Logical volume "lv_root" created.
root@ubuntu-learn:~#
oot@ubuntu-learn:~# mkfs.ext4 /dev/vg_root/lv_root
mke2fs 1.47.1 (20-May-2024)
/dev/vg_root/lv_root contains a ext4 file system
	last mounted on /lvroot on Mon Mar 24 05:19:37 2025
Proceed anyway? (y,N) y
Creating filesystem with 2620416 4k blocks and 655360 inodes
Filesystem UUID: c84e59e0-3fec-4f45-ab94-b7d25dfcb13b
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
root@ubuntu-learn:~#


<!-- ============= Монтирование и перенос данных ============= -->

root@ubuntu-learn:~# mkdir /lvroot
root@ubuntu-learn:~#
root@ubuntu-learn:~# mount /dev/vg_root/lv_root /lvroot
root@ubuntu-learn:~# rsync -avxHAX --progress / /lvroot/
...
sent 4.614.494.469 bytes  received 2.268.330 bytes  72.704.925,97 bytes/sec
total size is 4.609.405.999  speedup is 1,00
root@ubuntu-learn:~#ls /lvroot/
bin  boot  cdrom  dev  etc  home  lib  lib64  lost+found  lvroot  media  mnt  opt  proc  root  run  sbin  snap  srv  swap.img  sys  tmp  usr  var
root@ubuntu-learn:~#
root@ubuntu-learn:~# for i in /proc/ /sys/ /dev/ /run/ /boot/;  do mount --bind $i /lvroot/$i; done
root@ubuntu-learn:~# chroot /lvroot/

<!-- ============= Обновление grub ============= -->

root@ubuntu-learn:/# grub-mkconfig -o /boot/grub/grub.cfg
Sourcing file `/etc/default/grub'
Sourcing file `/etc/default/grub.d/kdump-tools.cfg'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.11.0-19-generic
Found initrd image: /boot/initrd.img-6.11.0-19-generic
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
Adding boot menu entry for UEFI Firmware Settings ...
done
root@ubuntu-learn:/# update-initramfs -u
root@ubuntu-learn:/#
exit
root@ubuntu-learn:/# reboot

<!-- ============= Загрузка во временный LVM ============= -->

root@ubuntu-learn:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   20G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1,8G  0 part /boot
└─sda3                      8:3    0 18,2G  0 part
  └─ubuntu--vg-ubuntu--lv 252:1    0   10G  0 lvm
sdb                         8:16   0    1G  0 disk
sdc                         8:32   0    1G  0 disk
sdd                         8:48   0    1G  0 disk
sde                         8:64   0    1G  0 disk
sdf                         8:80   0    1G  0 disk
sdg                         8:96   0    1G  0 disk
sdh                         8:112  0   10G  0 disk
└─vg_root-lv_root         252:0    0   10G  0 lvm  /
sr0                        11:0    1 1024M  0 rom


<!-- ============= Уменьшаем основной LV и создаем файловую систему ============= -->

root@ubuntu-learn:~#
root@ubuntu-learn:~# lvcreate -n ubuntu-vg/ubuntu-lv -L 8G /dev/ubuntu-vg
WARNING: ext4 signature detected on /dev/ubuntu-vg/ubuntu-lv at offset 1080. Wipe it? [y/n]: y
  Wiping ext4 signature on /dev/ubuntu-vg/ubuntu-lv.
  Logical volume "ubuntu-lv" created.
root@ubuntu-learn:~# mkfs.ext4 /dev/ubuntu-vg/ubuntu-lv
mke2fs 1.47.1 (20-May-2024)
Creating filesystem with 2097152 4k blocks and 524288 inodes
Filesystem UUID: 539698c9-7f1b-460e-afa3-016d2b50716c
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

<!-- ============= Повторяем монтирование, перенос данных и обновление загрузчика ============= -->

root@ubuntu-learn:~#
root@ubuntu-learn:/# mount /dev/ubuntu-vg/ubuntu-lv /lvroot/
mount: /dev/ubuntu-vg/ubuntu-lv: can't find in /etc/fstab.
root@ubuntu-learn:/# rsync -avxHAX --progress / /lvroot/
....
sent 4.342.158.852 bytes  received 1.610.055 bytes  87.752.907,21 bytes/sec
total size is 4.339.391.843  speedup is 1,00
root@ubuntu-learn:/#
root@ubuntu-learn:/# for i in /proc/ /sys/ /dev/ /run/ /boot/;  do mount --bind $i /lvroot/$i; done
root@ubuntu-learn:/# chroot /lvroot/
root@ubuntu-learn:/# grub-mkconfig -o /boot/grub/grub.cfg
Sourcing file `/etc/default/grub'
Sourcing file `/etc/default/grub.d/kdump-tools.cfg'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.11.0-19-generic
Found initrd image: /boot/initrd.img-6.11.0-19-generic
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
Adding boot menu entry for UEFI Firmware Settings ...
done

<!-- 2.	Перенести var на зеркальный LVM.; -->

<!-- ============= Cоздаем LVM для переноса ============= -->

root@ubuntu-learn:/#
root@ubuntu-learn:/# pvcreate /dev/sdc /dev/sdb
  Physical volume "/dev/sdc" successfully created.
  Physical volume "/dev/sdb" successfully created.
root@ubuntu-learn:/# vgcreate vg_var  /dev/sdc /dev/sdb
  Volume group "vg_var" successfully created
root@ubuntu-learn:/# lvcreate -L 950M -m1 -n lv_var vg_var
  Rounding up size to full physical extent 952,00 MiB
WARNING: ext4 signature detected on /dev/vg_var/lv_var at offset 1080. Wipe it? [y/n]: y
  Wiping ext4 signature on /dev/vg_var/lv_var.
  Logical volume "lv_var" created.
root@ubuntu-learn:/# mkfs.ext4 /dev/vg_var/lv_var
mke2fs 1.47.1 (20-May-2024)
Creating filesystem with 243712 4k blocks and 60928 inodes
Filesystem UUID: d7640bbc-8fea-4838-9cc6-1b7c921ae28e
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

<!-- ============= Монтирование и перенос данных ============= -->

root@ubuntu-learn:/# mount /dev/vg_var/lv_var /mnt
root@ubuntu-learn:/# cp -aR /var/* /mnt/

root@ubuntu-learn:/# mount /dev/vg_var/lv_var /mnt
root@ubuntu-learn:/# cp -aR /var/* /mnt/
root@ubuntu-learn:/# rm -rf /var/*
root@ubuntu-learn:/# ls /var/
root@ubuntu-learn:/# umount /mnt
root@ubuntu-learn:/# mount /dev/vg_var/lv_var /var
root@ubuntu-learn:/# ls var
backups  cache  crash  lib  local  lock  log  lost+found  mail  opt  run  snap  spool  tmp

<!-- ============= Настройка автоматического монтирования ============= -->

root@ubuntu-learn:/# echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
root@ubuntu-learn:/# cat /etc/fstab
.....
UUID="d7640bbc-8fea-4838-9cc6-1b7c921ae28e" /var ext4 defaults 0 0
root@ubuntu-learn:/#
exit
root@ubuntu-learn:/# reboot

<!-- 3. Выделить том под /home; -->

debugger@ubuntu-learn:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   20G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0  1,8G  0 part /boot
└─sda3                      8:3    0 18,2G  0 part
  └─ubuntu--vg-ubuntu--lv 252:1    0    8G  0 lvm  /
sdb                         8:16   0   10G  0 disk
└─vg_root-lv_root         252:0    0   10G  0 lvm
sdc                         8:32   0    1G  0 disk
├─vg_var-lv_var_rmeta_1   252:4    0    4M  0 lvm
│ └─vg_var-lv_var         252:6    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_1  252:5    0  952M  0 lvm
  └─vg_var-lv_var         252:6    0  952M  0 lvm  /var
sdd                         8:48   0    1G  0 disk
├─vg_var-lv_var_rmeta_0   252:2    0    4M  0 lvm
│ └─vg_var-lv_var         252:6    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_0  252:3    0  952M  0 lvm
  └─vg_var-lv_var         252:6    0  952M  0 lvm  /var
sde                         8:64   0    1G  0 disk
sdf                         8:80   0    1G  0 disk
sdg                         8:96   0    1G  0 disk
sdh                         8:112  0    1G  0 disk
sr0                        11:0    1 1024M  0 rom

<!-- ============= Взамен временного LVM пересоздаем LVM для /home ============= -->
root@ubuntu-learn:~# lvremove /dev/vg_root/lv_root
Do you really want to remove and DISCARD active logical volume vg_root/lv_root? [y/n]: y
  Logical volume "lv_root" successfully removed.
root@ubuntu-learn:~# vgremove vg_root
  Volume group "vg_root" successfully removed
root@ubuntu-learn:~# vgcreate vg-home /dev/sdb
  Volume group "vg-home" successfully created
root@ubuntu-learn:~# lvcreate -n lv-home -L 5G /dev/vg-home
WARNING: ext4 signature detected on /dev/vg-home/lv-home at offset 1080. Wipe it? [y/n]: y
  Wiping ext4 signature on /dev/vg-home/lv-home.
  Logical volume "lv-home" created.
root@ubuntu-learn:~# mkfs.ext4 /dev/vg-home/lv-home
mke2fs 1.47.1 (20-May-2024)
Creating filesystem with 1310720 4k blocks and 327680 inodes
Filesystem UUID: b3919fde-5584-4be2-b3d6-8ae3bb204d39
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

<!-- ============= Монтирование и перенос данных ============= -->

root@ubuntu-learn:~# mount /dev/vg-home/lv-home /mnt
root@ubuntu-learn:~# cp -aR /home/* /mnt/
root@ubuntu-learn:~# ls /mnt
debugger  lost+found
root@ubuntu-learn:~# rm -rf /home/*
root@ubuntu-learn:~# umount /mnt
root@ubuntu-learn:~# mount /dev/vg-home/lv-home /home/

<!-- ============= Настройка автоматического монтирования ============= -->

root@ubuntu-learn:~# echo "`blkid | grep home | awk '{print $2}'`  /home ext4 defaults 0 0" >> /etc/fstab
root@ubuntu-learn:~# cat /etc/fstab
.....
UUID="d7640bbc-8fea-4838-9cc6-1b7c921ae28e" /var ext4 defaults 0 0
UUID="b3919fde-5584-4be2-b3d6-8ae3bb204d39"  /home ext4 defaults 0 0
root@ubuntu-learn:~#

<!-- 4. Снапшоты; -->

root@ubuntu-learn:~# touch /home/file{1..20}
root@ubuntu-learn:~# ls /home
debugger  file10  file12  file14  file16  file18  file2   file3  file5  file7  file9
file1     file11  file13  file15  file17  file19  file20  file4  file6  file8  lost+found

<!-- ============= Создание lvm под snapshot ============= -->

root@ubuntu-learn:/# lvcreate -s -n lv-snap -L 1G /dev/vg-home/lv-home
  Logical volume "lv-snap" created.
root@ubuntu-learn:/#
root@ubuntu-learn:/# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
........
sdb                         8:16   0   10G  0 disk
├─vg--home-lv--home-real  252:7    0    5G  0 lvm
│ ├─vg--home-lv--home     252:0    0    5G  0 lvm  /home
│ └─vg--home-lv--snap     252:9    0    5G  0 lvm
└─vg--home-lv--snap-cow   252:8    0    1G  0 lvm
  └─vg--home-lv--snap     252:9    0    5G  0 lvm
........
root@ubuntu-learn:/#
root@ubuntu-learn:/# lvs
  LV        VG        Attr       LSize   Pool Origin  Data%  Meta%  Move Log Cpy%Sync Convert
  ubuntu-lv ubuntu-vg -wi-ao----   8,00g
  lv-home   vg-home   owi-a-s---   5,00g
  lv-snap   vg-home   swi-a-s---   1,00g      lv-home 0,01
  lv_var    vg_var    rwi-aor--- 952,00m                                     100,00
root@ubuntu-learn:/#
root@ubuntu-learn:/# vgs -o +lv_size,lv_name | grep home
  vg-home     1   2   1 wz--n- <10,00g  <4,00g   5,00g lv-home
  vg-home     1   2   1 wz--n- <10,00g  <4,00g   1,00g lv-snap
root@ubuntu-learn:/# rm -f /home/file{11..20}
root@ubuntu-learn:~# ls /home
debugger  file1  file10  file2  file3  file4  file5  file6  file7  file8  file9  lost+found

<!-- ============= Восстановление lvm из snapshot ============= -->

root@ubuntu-learn:/# umount /home
root@ubuntu-learn:/# lvconvert --merge /dev/vg-home/lv-snap
  Merging of volume vg-home/lv-snap started.
  vg-home/lv-home: Merged: 100,00%
root@ubuntu-learn:/# mount /dev/vg-home/lv-home  /home/
mount: (hint) your fstab has been modified, but systemd still uses
       the old version; use 'systemctl daemon-reload' to reload.
root@ubuntu-learn:/# ls /home/
debugger  file10  file12  file14  file16  file18  file2   file3  file5  file7  file9
file1     file11  file13  file15  file17  file19  file20  file4  file6  file8  lost+found

<!-- ============= Проверяем что snapshot удалился ============= -->

root@ubuntu-learn:/# lvs
  LV        VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  ubuntu-lv ubuntu-vg -wi-ao----   8,00g
  lv-home   vg-home   -wi-ao----   5,00g
  lv_var    vg_var    rwi-aor--- 952,00m                                    100,00
root@ubuntu-learn:/#



