# Домашнее задание к занятию №24 Пользователи и группы. Авторизация и аутентификация_РАМ

### Цель домашнего задания
Научиться создавать пользователей и добавлять им ограничения
### Описание домашнего задания
Ограничить доступ к системе для всех пользователей, кроме группы администраторов, в выходные дни (суббота и воскресенье), за исключением праздничных дней.


Создадим [Vagrantfile](./Vagrantfile) 

        MACHINES = {
        :"pam" => {
                    :box_name => "generic/rocky9",
                    :cpus => 2,
                    :memory => 1024,
                    :ip => "192.168.57.10",
                    }
        }

        Vagrant.configure("2") do |config|
        MACHINES.each do |boxname, boxconfig|
            config.vm.box_check_update = false
            config.vbguest.no_install = true
            config.vm.synced_folder ".", "/vagrant", disabled: true
            config.vm.network "private_network", ip: boxconfig[:ip]
            config.vm.define boxname do |box|
            box.vm.box = boxconfig[:box_name]
            box.vm.box_version = boxconfig[:box_version]
            box.vm.host_name = boxname.to_s

            box.vm.provider "virtualbox" do |v|
                v.memory = boxconfig[:memory]
                v.cpus = boxconfig[:cpus]
            end
            
            # Ansible provisioner
            config.vm.provision "ansible" do |ansible|
                ansible.playbook = "provisioning/playbook.yml"
            end

            end
        end
        end

Настройка выполняется с помощью [ansible](./provisioning/playbook.yml) 
