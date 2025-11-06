# Домашнее задание к занятию №27 Резервное копирование


### Цель домашнего задания: Научиться настраивать резервное копирование с помощью утилиты Borg.

### Описание домашнего задания
1. Настроить стенд Vagrant с двумя виртуальными машинами: backup_server и client.
2. Настроить удаленный бэкап каталога /etc c сервера client при помощи borgbackup. Резервные копии должны соответствовать следующим критериям:
- директория для резервных копий /var/backup. Это должна быть отдельная точка монтирования. В данном случае для демонстрации размер не принципиален, достаточно будет и 2GB;
- репозиторий для резервных копий должен быть зашифрован ключом или паролем - на усмотрение студента;
- имя бэкапа должно содержать информацию о времени снятия бекапа;
- глубина бекапа должна быть год, хранить можно по последней копии на конец месяца, кроме последних трех. Последние три месяца должны содержать копии на каждый день. Т.е. должна быть правильно настроена политика удаления старых бэкапов;
- резервная копия снимается каждые 5 минут. Такой частый запуск в целях демонстрации;
- написан скрипт для снятия резервных копий. Скрипт запускается из соответствующей Cron джобы, либо systemd timer-а - на усмотрение студента;
- настроено логирование процесса бекапа. Для упрощения можно весь вывод перенаправлять в logger с соответствующим тегом. Если настроите не в syslog, то обязательна ротация логов.

### 1. Настроить стенд Vagrant с двумя виртуальными машинами: backup_server и client.

Стенд разворачиваем с помщью [Vagrantfile](./Vagrantfile) 

        Vagrant.configure("2") do |config|
        config.vm.box = "generic/rocky9"
        config.vm.box_check_update = false
        config.vbguest.no_install = true
        config.vm.provider :virtualbox do |v|
            v.memory = 1024
            v.cpus = 2
        end

        boxes = [
            { 
            :name => "backup",
            :ip => "192.168.56.160"
            },
            { 
            :name => "client",
            :ip => "192.168.56.150"
            }
        ]

        # Provision each of the VMs.
        boxes.each do |opts|
            config.vm.define opts[:name] do |vm_config|
            vm_config.vm.hostname = opts[:name]
            vm_config.vm.network "private_network", ip: opts[:ip]
            
            # Общая папка с ключами
            vm_config.vm.synced_folder "ssh-keys/", "/vagrant/ssh-keys"
            
            if opts[:name] == "backup"
                vm_config.vm.disk :disk, 
                size: "2GB", 
                name: "backup-disk",
                primary: false
            end
            
            # Ansible provision
            vm_config.vm.provision "ansible" do |ansible|
                ansible.playbook = "provisioning/playbook.yml"
                ansible.extra_vars = {
                node_name: opts[:name],
                node_ip: opts[:ip],
                }
                ansible.become = true
                ansible.verbose = "v"
            end
            end
        end
        end

### 2. Настроить удаленный бэкап каталога /etc c сервера client при помощи borgbackup.

Установка и настройка выполняется с помощью [ansible playbook](./provisioning/playbook.yml) 
после того, как стенд собран, проверяем его работоспособность:

Важно, перед запуском нужно сгенерировать ключи в каталоге ssh-keys

        ssh-keygen -t ed25519 -C "borg-client" -f ssh-keys/id_ed25519 -N ""

##### - директория для резервных копий /var/backup.

        [vagrant@backup ~]$ lsblk
        NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
        sda                  8:0    0  128G  0 disk 
        ├─sda1               8:1    0    1G  0 part /boot
        └─sda2               8:2    0  127G  0 part 
        ├─rl_rocky9-root 253:0    0   70G  0 lvm  /
        └─rl_rocky9-swap 253:1    0    2G  0 lvm  [SWAP]
        sdb                  8:16   0    2G  0 disk /var/backup

##### - репозиторий для резервных копий должен быть зашифрован ключом или паролем

        [vagrant@backup ~]$ sudo -u borg ls -la /var/backup/
        total 80
        drwxr-xr-x.  3 borg borg  4096 Nov  6 05:12 .
        drwxr-xr-x. 20 root root  4096 Nov  5 19:45 ..
        -rw-------.  1 borg borg   700 Nov  6 05:12 config
        drwx------.  3 borg borg  4096 Nov  5 19:47 data
        -rw-------.  1 borg borg  8190 Nov  6 05:12 hints.473
        -rw-------.  1 borg borg 41258 Nov  6 05:12 index.473
        -rw-------.  1 borg borg   190 Nov  6 05:12 integrity.473
        -rw-------.  1 borg borg    16 Nov  6 05:12 nonce
        -rw-------.  1 borg borg    73 Nov  5 19:47 README
        [vagrant@backup ~]$ sudo -u borg cat /var/backup/config 
        [repository]
        version = 1
        segments_per_dir = 1000
        max_segment_size = 524288000
        append_only = 0
        storage_quota = 0
        additional_free_space = 0
        id = efc7fdca64f8f860291db697a4b9a2123dccad9ef4047bc7da1fea1367ef2b94
        key = hqlhbGdvcml0aG2mc2hhMjU2pGRhdGHaAN7ipi1cvJa8K92QYWJg++iNgKCWDCUI1O0df/
                Fie683FNaDcs+7kEaY/uO3dW01G1ua9aJntueRY8bCXhlelkci5eX8CZdfnURnjlQ8NPhe
                KsT/FJMVhdmu69upHGB34xd5io0QE47sumzOKsFPe7QyrSIe/S59eSD6uCa3Py3adbbOeJ
                N4EuWsGkROjwuBdcCzFEz/9emb5rQAo72OJEH2V8YtRF3277p2MCbdiPuJ9sCB28+L4amE
                mp3NzCYngxchRpOZgyA1V9U8U3Sko7jgKT5P7wWPMA+kGd/y66+kaGFzaNoAIBrjIKVSFr
                cj4XuVco1bShCFkRnUUcXZ31q6uXm4uyfQqml0ZXJhdGlvbnPOAAGGoKRzYWx02gAg8MJQ
                AumrKzqV6onrPgsEG0DnHm3Sj98Jso2IqLI6CXOndmVyc2lvbgE=

##### - имя бэкапа должно содержать информацию о времени снятия бекапа;

        [vagrant@client ~]$ BORG_RSH="ssh -i /home/vagrant/.ssh/borg_key -o StrictHostKeyChecking=no" borg list borg@192.168.56.160:/var/backup/
        Enter passphrase for key ssh://borg@192.168.56.160/var/backup: 
        etc-test-1762372023                  Wed, 2025-11-05 19:47:07 [3d9bb2b48cb4218d851c1f64dd7dab141e6300266520314ecd3c9fc306573bc7]
        etc-test-1762372444                  Wed, 2025-11-05 19:54:08 [7999b76065be35ed90061d525cfa18f8ab2790bc6a2de4c8c361b7f2c481b854]
        etc-2025-11-05_19:54:11              Wed, 2025-11-05 19:54:12 [43ddf1e70c5aa3c4f5b38a32eb886f647d420c9cd1627017e244afe1e4eb0a26]
        etc-2025-11-05_19:59:34              Wed, 2025-11-05 19:59:35 [4a4bfbe3ab8f138efff5dfc5ff6363318e83c587803af6f256ca3cb50e86494c]
        etc-test-1762372875                  Wed, 2025-11-05 20:01:20 [8fb2662d549197fb7ee50c3f5846ec0422fc1f236044100a916a2da553d6c93a]
        etc-2025-11-05_20:10:07              Wed, 2025-11-05 20:10:08 [89368aaa0c727d41901b19918474b9ea14bdb18cd3a4e204937f5e8dcfee3f16]
        etc-2025-11-05_20:16:07              Wed, 2025-11-05 20:16:08 [78965cdcecec636daef1214aed17190997ca771be85fa0c4f1875d22032cdaf6]
        etc-2025-11-05_20:21:08              Wed, 2025-11-05 20:21:08 [e2142cb31ace598d120040392804391d5eb16ec780dbeff947c0361a5301ad2f]
        etc-2025-11-05_20:27:05              Wed, 2025-11-05 20:27:05 [c400e4b8a1ebc3c113fcacbec43895aca031f303ce8148cf597fdf68c6c5116e]
        etc-2025-11-05_20:32:05              Wed, 2025-11-05 20:32:06 [9bf9aad02db33e6086fef2131e88b40dc90f55c305ccaf646dee1d76b67aa966]
        etc-2025-11-05_20:37:05              Wed, 2025-11-05 20:37:06 [a7ec30dc8bf1e7f4a6cca46285cab269fc41c9cc5e0851faf9869072b0fc47da]
        etc-2025-11-05_20:42:06              Wed, 2025-11-05 20:42:07 [9b3bc63de4ae0b5c5870add44e5ec0b5161e89cca039fa19cd1bb83c8ce0ec55]
        etc-2025-11-05_20:47:06              Wed, 2025-11-05 20:47:07 

##### - глубина бекапа должна быть год, хранить можно по последней копии на конец месяца, кроме последних трех. Последние три месяца должны содержать копии на каждый день. Т.е. должна быть правильно настроена политика удаления старых бэкапов;

Ну на год я не накопил ))) Но вот часть кода настройки [сервиса, которая за это отвечает](./provisioning/templates/borg-backup.service.j2)

            ExecStartPost=/bin/sh -c '\
            echo "$(date): Starting prune operation" | tee -a /var/log/borg-backup/backup.log | logger -t borg-backup && \
            borg prune \
                --lock-wait 30 \
                --keep-daily 90 \
                --keep-monthly 12 \
                --keep-yearly 1 \
                ${REPO} 2>&1 | tee -a /var/log/borg-backup/backup.log | logger -t borg-backup && \
            echo "$(date): Prune operation completed" | tee -a /var/log/borg-backup/backup.log | logger -t borg-backup'

##### - резервная копия снимается каждые 5 минут. Такой частый запуск в целях демонстрации;

Демонстрирует опять же вот этот вывод

        [vagrant@client ~]$ BORG_RSH="ssh -i /home/vagrant/.ssh/borg_key -o StrictHostKeyChecking=no" borg list borg@192.168.56.160:/var/backup/
        Enter passphrase for key ssh://borg@192.168.56.160/var/backup: 
        etc-test-1762372023                  Wed, 2025-11-05 19:47:07 [3d9bb2b48cb4218d851c1f64dd7dab141e6300266520314ecd3c9fc306573bc7]
        etc-test-1762372444                  Wed, 2025-11-05 19:54:08 [7999b76065be35ed90061d525cfa18f8ab2790bc6a2de4c8c361b7f2c481b854]
        etc-2025-11-05_19:54:11              Wed, 2025-11-05 19:54:12 [43ddf1e70c5aa3c4f5b38a32eb886f647d420c9cd1627017e244afe1e4eb0a26]
        etc-2025-11-05_19:59:34              Wed, 2025-11-05 19:59:35 [4a4bfbe3ab8f138efff5dfc5ff6363318e83c587803af6f256ca3cb50e86494c]
        etc-test-1762372875                  Wed, 2025-11-05 20:01:20 [8fb2662d549197fb7ee50c3f5846ec0422fc1f236044100a916a2da553d6c93a]
        etc-2025-11-05_20:10:07              Wed, 2025-11-05 20:10:08 [89368aaa0c727d41901b19918474b9ea14bdb18cd3a4e204937f5e8dcfee3f16]
        etc-2025-11-05_20:16:07              Wed, 2025-11-05 20:16:08 [78965cdcecec636daef1214aed17190997ca771be85fa0c4f1875d22032cdaf6]
        etc-2025-11-05_20:21:08              Wed, 2025-11-05 20:21:08 [e2142cb31ace598d120040392804391d5eb16ec780dbeff947c0361a5301ad2f]
        etc-2025-11-05_20:27:05              Wed, 2025-11-05 20:27:05 [c400e4b8a1ebc3c113fcacbec43895aca031f303ce8148cf597fdf68c6c5116e]
        etc-2025-11-05_20:32:05              Wed, 2025-11-05 20:32:06 [9bf9aad02db33e6086fef2131e88b40dc90f55c305ccaf646dee1d76b67aa966]
        etc-2025-11-05_20:37:05              Wed, 2025-11-05 20:37:06 [a7ec30dc8bf1e7f4a6cca46285cab269fc41c9cc5e0851faf9869072b0fc47da]
        etc-2025-11-05_20:42:06              Wed, 2025-11-05 20:42:07 [9b3bc63de4ae0b5c5870add44e5ec0b5161e89cca039fa19cd1bb83c8ce0ec55]
        etc-2025-11-05_20:47:06              Wed, 2025-11-05 20:47:07 

##### - написан скрипт для снятия резервных копий. Скрипт запускается из соответствующей Cron джобы, либо systemd timer-а

[Шаблон сервиса](./provisioning/templates/borg-backup.service.j2) 
[Шаблон таймера](./provisioning/templates/borg-backup.timer.j2) 

##### - настроено логирование процесса бекапа. Для упрощения можно весь вывод перенаправлять в logger с соответствующим тегом. Если настроите не в syslog, то обязательна ротация логов.

Логирование настроено в [конфигурации сервиса](./provisioning/templates/borg-backup.service.j2), ротация логов в [файле](./provisioning/templates/borg-backup.j2)

Демонстрация syslog

        [vagrant@client ~]$ sudo journalctl -t borg-backup -f
        Nov 06 05:40:09 client borg-backup[9986]: All archives:               79.35 MB             27.23 MB              6.92 MB
        Nov 06 05:40:09 client borg-backup[9986]: 
        Nov 06 05:40:09 client borg-backup[9986]:                        Unique chunks         Total chunks
        Nov 06 05:40:09 client borg-backup[9986]: Chunk index:                     358                 1420
        Nov 06 05:40:09 client borg-backup[9986]: ------------------------------------------------------------------------------
        Nov 06 05:40:09 client borg-backup[9991]: Thu Nov  6 05:40:09 AM UTC 2025: Backup creation completed
        Nov 06 05:40:09 client borg-backup[9997]: Thu Nov  6 05:40:09 AM UTC 2025: Starting repository check
        Nov 06 05:40:10 client borg-backup[10004]: Thu Nov  6 05:40:10 AM UTC 2025: Repository check completed
        Nov 06 05:40:10 client borg-backup[10009]: Thu Nov  6 05:40:10 AM UTC 2025: Starting prune operation
        Nov 06 05:40:11 client borg-backup[10018]: Thu Nov  6 05:40:11 AM UTC 2025: Prune operation completed

Демонстрация файловых логов

        [vagrant@client ~]$ sudo tail -n 25 /var/log/borg-backup/backup.log
        /etc/polkit-1/rules.d: dir_open: [Errno 13] Permission denied: 'rules.d'
        /etc/polkit-1/localauthority: dir_open: [Errno 13] Permission denied: 'localauthority'
        /etc/sudoers.d: dir_open: [Errno 13] Permission denied: 'sudoers.d'
        ------------------------------------------------------------------------------
        Repository: ssh://borg@192.168.56.160/var/backup
        Archive name: etc-2025-11-06_05:40:07
        Archive fingerprint: f09d3974ebb3a15070b443c89ae8f26d9aac44b008d247f9998394be7f11d8ae
        Time (start): Thu, 2025-11-06 05:40:08
        Time (end):   Thu, 2025-11-06 05:40:08
        Duration: 0.10 seconds
        Number of files: 358
        Utilization of max. archive size: 0%
        ------------------------------------------------------------------------------
                            Original size      Compressed size    Deduplicated size
        This archive:               19.84 MB              6.81 MB                599 B
        All archives:               79.35 MB             27.23 MB              6.92 MB

                            Unique chunks         Total chunks
        Chunk index:                     358                 1420
        ------------------------------------------------------------------------------
        Thu Nov  6 05:40:09 AM UTC 2025: Backup creation completed
        Thu Nov  6 05:40:09 AM UTC 2025: Starting repository check
        Thu Nov  6 05:40:10 AM UTC 2025: Repository check completed
        Thu Nov  6 05:40:10 AM UTC 2025: Starting prune operation
        Thu Nov  6 05:40:11 AM UTC 2025: Prune operation completed



