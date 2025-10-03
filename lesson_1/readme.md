Last login: Tue Mar 11 08:04:26 2025
debugger@ubuntu-learn:~$ cat /proc/version_signature
Ubuntu 5.4.0-208.228-generic 5.4.286
debugger@ubuntu-learn:~$ uname -a
Linux ubuntu-learn 5.4.0-208-generic #228-Ubuntu SMP Fri Feb 7 19:41:33 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
debugger@ubuntu-learn:~$ uname -r
5.4.0-208-generic
debugger@ubuntu-learn:~$ mkdir kernel
debugger@ubuntu-learn:~$ cd kernel/
debugger@ubuntu-learn:~/kernel$ wget  https://kernel.ubuntu.com/mainline/v5.5/linux-headers-5.5.0-050500_5.5.0-050500.202001262030_all.deb
--2025-03-11 08:18:42--  https://kernel.ubuntu.com/mainline/v5.5/linux-headers-5.5.0-050500_5.5.0-050500.202001262030_all.deb
Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 185.125.189.74, 185.125.189.76, 185.125.189.75
Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|185.125.189.74|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 10993964 (10M) [application/x-debian-package]
Saving to: ‘linux-headers-5.5.0-050500_5.5.0-050500.202001262030_all.deb’

linux-headers-5.5.0-050500_5.5.0-05 100%[===================================================================>]  10,48M  5,58MB/s    in 1,9s

2025-03-11 08:18:45 (5,58 MB/s) - ‘linux-headers-5.5.0-050500_5.5.0-050500.202001262030_all.deb’ saved [10993964/10993964]

debugger@ubuntu-learn:~/kernel$ wget  https://kernel.ubuntu.com/mainline/v5.5/linux-headers-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb
--2025-03-11 08:18:45--  https://kernel.ubuntu.com/mainline/v5.5/linux-headers-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb
Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 185.125.189.74, 185.125.189.76, 185.125.189.75
Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|185.125.189.74|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1188496 (1,1M) [application/x-debian-package]
Saving to: ‘linux-headers-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb’

linux-headers-5.5.0-050500-generic_ 100%[===================================================================>]   1,13M  2,18MB/s    in 0,5s

2025-03-11 08:18:46 (2,18 MB/s) - ‘linux-headers-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb’ saved [1188496/1188496]

debugger@ubuntu-learn:~/kernel$ wget  https://kernel.ubuntu.com/mainline/v5.5/linux-image-unsigned-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb
--2025-03-11 08:18:47--  https://kernel.ubuntu.com/mainline/v5.5/linux-image-unsigned-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb
Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 185.125.189.74, 185.125.189.76, 185.125.189.75
Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|185.125.189.74|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 8996016 (8,6M) [application/x-debian-package]
Saving to: ‘linux-image-unsigned-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb’

linux-image-unsigned-5.5.0-050500-g 100%[===================================================================>]   8,58M  3,98MB/s    in 2,2s

2025-03-11 08:18:50 (3,98 MB/s) - ‘linux-image-unsigned-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb’ saved [8996016/8996016]

debugger@ubuntu-learn:~/kernel$ wget  https://kernel.ubuntu.com/mainline/v5.5/linux-modules-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb
--2025-03-11 08:18:52--  https://kernel.ubuntu.com/mainline/v5.5/linux-modules-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb
Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 185.125.189.74, 185.125.189.76, 185.125.189.75
Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|185.125.189.74|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 52022372 (50M) [application/x-debian-package]
Saving to: ‘linux-modules-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb’

linux-modules-5.5.0-050500-generic_ 100%[===================================================================>]  49,61M  8,23MB/s    in 6,8s

2025-03-11 08:18:59 (7,25 MB/s) - ‘linux-modules-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb’ saved [52022372/52022372]

debugger@ubuntu-learn:~/kernel$ ls
linux-headers-5.5.0-050500_5.5.0-050500.202001262030_all.deb
linux-headers-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb
linux-image-unsigned-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb
linux-modules-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb
debugger@ubuntu-learn:~/kernel$ sudo dpkg -i *.deb
[sudo] password for debugger:
Выбор ранее не выбранного пакета linux-headers-5.5.0-050500.
(Чтение базы данных … на данный момент установлено 72539 файлов и каталогов.)
Подготовка к распаковке linux-headers-5.5.0-050500_5.5.0-050500.202001262030_all.deb …
Распаковывается linux-headers-5.5.0-050500 (5.5.0-050500.202001262030) …
Выбор ранее не выбранного пакета linux-headers-5.5.0-050500-generic.
Подготовка к распаковке linux-headers-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb …
Распаковывается linux-headers-5.5.0-050500-generic (5.5.0-050500.202001262030) …
Выбор ранее не выбранного пакета linux-image-unsigned-5.5.0-050500-generic.
Подготовка к распаковке linux-image-unsigned-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb …
Распаковывается linux-image-unsigned-5.5.0-050500-generic (5.5.0-050500.202001262030) …
Выбор ранее не выбранного пакета linux-modules-5.5.0-050500-generic.
Подготовка к распаковке linux-modules-5.5.0-050500-generic_5.5.0-050500.202001262030_amd64.deb …
Распаковывается linux-modules-5.5.0-050500-generic (5.5.0-050500.202001262030) …
Настраивается пакет linux-headers-5.5.0-050500 (5.5.0-050500.202001262030) …
Настраивается пакет linux-headers-5.5.0-050500-generic (5.5.0-050500.202001262030) …
Настраивается пакет linux-modules-5.5.0-050500-generic (5.5.0-050500.202001262030) …
Настраивается пакет linux-image-unsigned-5.5.0-050500-generic (5.5.0-050500.202001262030) …
I: /boot/vmlinuz is now a symlink to vmlinuz-5.5.0-050500-generic
I: /boot/initrd.img is now a symlink to initrd.img-5.5.0-050500-generic
Обрабатываются триггеры для linux-image-unsigned-5.5.0-050500-generic (5.5.0-050500.202001262030) …
/etc/kernel/postinst.d/initramfs-tools:
update-initramfs: Generating /boot/initrd.img-5.5.0-050500-generic
/etc/kernel/postinst.d/zz-update-grub:
Sourcing file `/etc/default/grub'
Sourcing file `/etc/default/grub.d/init-select.cfg'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-5.5.0-050500-generic
Found initrd image: /boot/initrd.img-5.5.0-050500-generic
Found linux image: /boot/vmlinuz-5.4.0-208-generic
Found initrd image: /boot/initrd.img-5.4.0-208-generic
done
debugger@ubuntu-learn:~/kernel$  ls -al /boot
total 211784
drwxr-xr-x  4 root root     4096 мар 11 10:00 .
drwxr-xr-x 19 root root     4096 мар 11 07:34 ..
-rw-r--r--  1 root root   237889 фев  7 17:31 config-5.4.0-208-generic
-rw-r--r--  1 root root   239599 янв 27  2020 config-5.5.0-050500-generic
drwxr-xr-x  4 root root     4096 мар 11 10:00 grub
lrwxrwxrwx  1 root root       31 мар 11 10:00 initrd.img -> initrd.img-5.5.0-050500-generic
-rw-r--r--  1 root root 89377569 мар 11 08:07 initrd.img-5.4.0-208-generic
-rw-r--r--  1 root root 91321804 мар 11 10:00 initrd.img-5.5.0-050500-generic
lrwxrwxrwx  1 root root       28 мар 11 07:21 initrd.img.old -> initrd.img-5.4.0-208-generic
drwx------  2 root root    16384 мар 11 07:19 lost+found
-rw-------  1 root root  4766192 фев  7 17:31 System.map-5.4.0-208-generic
-rw-------  1 root root  5301159 янв 27  2020 System.map-5.5.0-050500-generic
lrwxrwxrwx  1 root root       28 мар 11 10:00 vmlinuz -> vmlinuz-5.5.0-050500-generic
-rw-------  1 root root 13710088 фев  7 17:53 vmlinuz-5.4.0-208-generic
-rw-------  1 root root 11864960 янв 27  2020 vmlinuz-5.5.0-050500-generic
lrwxrwxrwx  1 root root       25 мар 11 07:21 vmlinuz.old -> vmlinuz-5.4.0-208-generic
debugger@ubuntu-learn:~/kernel$  sudo update-grub
Sourcing file `/etc/default/grub'
Sourcing file `/etc/default/grub.d/init-select.cfg'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-5.5.0-050500-generic
Found initrd image: /boot/initrd.img-5.5.0-050500-generic
Found linux image: /boot/vmlinuz-5.4.0-208-generic
Found initrd image: /boot/initrd.img-5.4.0-208-generic
done
debugger@ubuntu-learn:~/kernel$  sudo update-grub
Sourcing file `/etc/default/grub'
Sourcing file `/etc/default/grub.d/init-select.cfg'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-5.5.0-050500-generic
Found initrd image: /boot/initrd.img-5.5.0-050500-generic
Found linux image: /boot/vmlinuz-5.4.0-208-generic
Found initrd image: /boot/initrd.img-5.4.0-208-generic
done
debugger@ubuntu-learn:~/kernel$ sudo reboot
Connection to 10.4.136.162 closed by remote host.
Connection to 10.4.136.162 closed.

debugger@ubuntu-learn:~$ uname -r
5.5.0-050500-generic
debugger@ubuntu-learn:~$