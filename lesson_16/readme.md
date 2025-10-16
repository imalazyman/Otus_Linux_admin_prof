# Д.З. 16 Автоматизация администрирования. Ansible-1

## Задание:
Подготовить стенд на Vagrant как минимум с одним сервером. На этом сервере используя Ansible необходимо развернуть nginx со следующими условиями:

- необходимо использовать модуль yum/apt;
- конфигурационные файлы должны быть взяты из шаблона jinja2 с перемененными;
- после установки nginx должен быть в режиме enabled в systemd;
- должен быть использован notify для старта nginx после установки;
- сайт должен слушать на нестандартном порту - 8080, для этого использовать переменные в Ansible.

Создадим [Vagrantfile](./Vagrantfile) 

        Vagrant.configure(2) do |config|
        config.vm.box = "centos/7"
        
        # Отключить автоматическое обновление Guest Additions чтобы избежать проблем с репозиториями
        config.vbguest.auto_update = false

        # Исправить репозитории CentOS 7
        config.vm.provision "shell", inline: <<-SHELL
            sed -i 's/mirror.centos.org/vault.centos.org/g' /etc/yum.repos.d/CentOS-*.repo
            sed -i 's/^#.*baseurl=http/baseurl=http/g' /etc/yum.repos.d/CentOS-*.repo
            sed -i 's/^mirrorlist=http/#mirrorlist=http/g' /etc/yum.repos.d/CentOS-*.repo
        SHELL

        # Ansible provisioner
        config.vm.provision "ansible" do |ansible|
            ansible.playbook = "provisioning/playbook.yml"
        end

        config.vm.provider "virtualbox" do |v|
            v.memory = 512
            v.cpus = 1
        end

        # VM с nginx
        config.vm.define "nginx-server" do |web|
            web.vm.hostname = "nginx-server"
            web.vm.network "private_network", ip: "192.168.56.10"
            # Проброс порта для доступа с хоста
            web.vm.network "forwarded_port", guest: 8080, host: 8080
        end
        end


[Ansible playbook](./provisioning/playbook.yml)
