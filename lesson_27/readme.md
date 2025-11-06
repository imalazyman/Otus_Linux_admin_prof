# Домашнее задание к занятию №27 Резервное копирование


### Цель домашнего задания: Научиться настраивать резервное копирование с помощью утилиты Borg.

### Описание домашнего задания
1. Настроить стенд Vagrant с двумя виртуальными машинами: backup_server и client.
2. Настроить удаленный бэкап каталога /etc c сервера client при помощи borgbackup. Резервные копии должны соответствовать следующим критериям:
- директория для резервных копий /var/backup. Это должна быть отдельная точка монтирования. В данном случае для демонстрации размер не принципиален, достаточно будет и 2GB; (Студент самостоятельно настраивает)
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