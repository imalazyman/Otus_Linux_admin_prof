# Домашнее задание к занятию №24 Основы сбора и хранения логов

### Цель домашнего задания: Научится проектировать централизованный сбор логов.

### Описание домашнего задания
1. В Vagrant разворачиваем 2 виртуальные машины web и log
2. на web настраиваем nginx
3. на log настраиваем центральный лог сервер на любой системе на выбор
- journald;
- rsyslog;
- elk.
4. настраиваем аудит, следящий за изменением конфигов nginx 

Все критичные логи с web должны собираться и локально и удаленно.
Все логи с nginx должны уходить на удаленный сервер (локально только критичные).
Логи аудита должны также уходить на удаленную систем


### 1. В Vagrant разворачиваем 2 виртуальные машины web и log

Стенд разворачиваем с помщью [Vagrantfile](./Vagrantfile) 

        Vagrant.configure("2") do |config|
        # Base VM OS configuration.
        config.vm.box = "generic/rocky9"
        config.vm.box_check_update = false
        config.vbguest.no_install = true
        config.vm.provider :virtualbox do |v|
            v.memory = 1024
            v.cpus = 2
            end

        # Define two VMs with static private IP addresses.
        boxes = [
            { :name => "web",
            :ip => "192.168.56.10",
            },
            { :name => "log",
            :ip => "192.168.56.15",
            }
        ]
        
        # Provision each of the VMs.
        boxes.each do |opts|
            config.vm.define opts[:name] do |config|
            config.vm.hostname = opts[:name]
            config.vm.network "private_network", ip: opts[:ip]
            
            # Ansible provision
            config.vm.provision "ansible" do |ansible|
                ansible.playbook = "provisioning/playbook.yml"
                ansible.extra_vars = {
                node_name: opts[:name],
                node_ip: opts[:ip],
                log_server_ip: "192.168.56.15"
                }
                end
            end
            end
        end

### 2-3 Настройка nginx и rsyslog

Установка и настройка выполняется с помощью [ansible playbook](./provisioning/playbook.yml) 
после того, как стенд собран, проверяем его работоспособность:


### На сервере web генерируем все типы логов:
        # 1. Нормальные запросы (access.log)
        for i in {1..2}; do curl http://localhost; done

        # 2. 404 ошибки (access.log)  
        curl http://localhost/nonexistent-page

        # 3. Настоящие ошибки (error.log)
        # На сервере web создадим синтаксическую ошибку в конфиге nginx
        sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
        echo "invalid_directive test;" | sudo tee -a /etc/nginx/nginx.conf
        sudo nginx -t
        sudo systemctl reload nginx
        # после чего восстанавливаем конфиг
        sudo cp /etc/nginx/nginx.conf.backup /etc/nginx/nginx.conf
        sudo nginx -t
        sudo systemctl reload nginx

        # 4. Критичные логи
        logger -p daemon.crit "TEST CRITICAL MESSAGE"

        # 5. События аудита
        sudo touch /etc/nginx/nginx.conf

### На сервере log проверяем

#### 1 . Нормальные запросы (access.log)
        
        $ sudo cat /var/log/remote/web/nginx-access.log
        Nov  4 14:29:26 web nginx-access 127.0.0.1 - - [04/Nov/2025:14:29:26 +0000] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1"
        Nov  4 14:29:26 web nginx-access 127.0.0.1 - - [04/Nov/2025:14:29:26 +0000] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
        Nov  4 14:29:26 web nginx-access 127.0.0.1 - - [04/Nov/2025:14:29:26 +0000] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1"
        Nov  4 14:29:26 web nginx-access 127.0.0.1 - - [04/Nov/2025:14:29:26 +0000] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"

#### 2. 404 ошибки (access.log) 
        
        $ sudo cat /var/log/remote/web/nginx-access.log
        Nov  4 14:29:26 web nginx-access 127.0.0.1 - - [04/Nov/2025:14:29:26 +0000] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1"
        Nov  4 14:29:26 web nginx-access 127.0.0.1 - - [04/Nov/2025:14:29:26 +0000] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
        Nov  4 14:29:26 web nginx-access 127.0.0.1 - - [04/Nov/2025:14:29:26 +0000] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1"
        Nov  4 14:29:26 web nginx-access 127.0.0.1 - - [04/Nov/2025:14:29:26 +0000] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
        Nov  4 14:32:25 web nginx-access 127.0.0.1 - - [04/Nov/2025:14:32:25 +0000] "GET /invalid-page HTTP/1.1" 404 3332 "-" "curl/7.76.1" "-"
        Nov  4 14:32:25 web nginx-access 127.0.0.1 - - [04/Nov/2025:14:32:25 +0000] "GET /invalid-page HTTP/1.1" 404 3332 "-" "curl/7.76.1"
        Nov  4 14:32:25 web nginx-access 127.0.0.1 - - [04/Nov/2025:14:32:25 +0000] "GET /nonexistent HTTP/1.1" 404 3332 "-" "curl/7.76.1" "-"
        Nov  4 14:32:25 web nginx-access 127.0.0.1 - - [04/Nov/2025:14:32:25 +0000] "GET /nonexistent HTTP/1.1" 404 3332 "-" "curl/7.76.1"

#### 3. Настоящие ошибки (error.log)

        $ sudo cat /var/log/remote/web/nginx-error.log
        Nov  4 14:38:23 web nginx-error 2025/11/04 14:38:23 [emerg] 9656#9656: unknown directive "invalid_directive" in /etc/nginx/nginx.conf:85
        Nov  4 14:38:53 web nginx-error 2025/11/04 14:38:53 [emerg] 9661#9661: unknown directive "invalid_directive" in /etc/nginx/nginx.conf:85
        Nov  4 14:40:05 web nginx-error 2025/11/04 14:40:05 [notice] 9677#9677: signal process started

#### 4. Критичные логи

        $ sudo cat /var/log/remote/critical/web-vagrant.log
        Nov  4 14:45:29 web vagrant[9734]: TEST CRITICAL MESSAGE   


#### 5. События аудита
[vagrant@log ~]$ sudo cat /var/log/remote/web/nginx-audit.log
Nov  4 19:20:16 web nginx-audit[14826]: Audit: type=CONFIG_CHANGE msg=audit(1762282095.110:1708): auid=1000 ses=4 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 op=add_rule key="nginx_config" list=4 res=1#035AUID="vagrant"
Nov  4 19:20:26 web nginx-audit[14917]: Audit: type=SYSCALL msg=audit(1762284024.701:7245): arch=c000003e syscall=257 success=yes exit=3 a0=ffffff9c a1=7ffec07b88d2 a2=941 a3=1b6 items=2 ppid=14870 pid=14872 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=5 comm="touch" exe="/usr/bin/touch" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="nginx_config"#035ARCH=x86_64 SYSCALL=openat AUID="vagrant" UID="root" GID="root" EUID="root" SUID="root" FSUID="root" EGID="root" SGID="root" FSGID="root"
Nov  4 19:22:32 web nginx-audit[15572]: DIRECT TEST
Nov  4 19:23:20 web nginx-audit[15840]: Audit: type=CONFIG_CHANGE msg=audit(1762282095.110:1708): auid=1000 ses=4 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 op=add_rule key="nginx_config" list=4 res=1#035AUID="vagrant"
Nov  4 19:23:35 web nginx-audit[15951]: Audit: type=SYSCALL msg=audit(1762284211.905:8440): arch=c000003e syscall=257 success=yes exit=3 a0=ffffff9c a1=7ffcccc908d2 a2=941 a3=1b6 items=2 ppid=15904 pid=15906 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=5 comm="touch" exe="/usr/bin/touch" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="nginx_config"#035ARCH=x86_64 SYSCALL=openat AUID="vagrant" UID="root" GID="root" EUID="root" SUID="root" FSUID="root" EGID="root" SGID="root" FSGID="root"