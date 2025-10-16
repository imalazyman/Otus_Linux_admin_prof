# Д.З. 16 Автоматизация администрирования. Ansible-1

## Задание:
Подготовить стенд на Vagrant как минимум с одним сервером. На этом сервере используя Ansible необходимо развернуть nginx со следующими условиями:

- необходимо использовать модуль yum/apt;
- конфигурационные файлы должны быть взяты из шаблона jinja2 с перемененными;
- после установки nginx должен быть в режиме enabled в systemd;
- должен быть использован notify для старта nginx после установки;
- сайт должен слушать на нестандартном порту - 8080, для этого использовать переменные в Ansible.

Создадим [Vagrantfile](./Vagrantfile) 

Провиженинг сделаем через ansible

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

        ---
        - name: Deploy and configure Nginx on CentOS 7
        hosts: all
        become: yes
        vars_files:
            - [vars/default.yml](./provisioning/vars/default.yml) # Файл с переменными

        tasks:
            # Для установки ngix нужен epel репозиторий
            - name: Install EPEL repository (required for nginx on CentOS 7) # Для установки ngix нужен epel репозиторий
            yum:
                name: epel-release
                state: present

            - name: Install packages
            yum:
                name:
                # Устаннавливаем nginx и пакеты для управления SELinux
                - nginx
                - policycoreutils-python
                - policycoreutils-newrole

                state: latest
            notify:
                - Enable nginx service # Добавляем nginx в автозагрузку
                - Start nginx service  # Стартуем nginx

            - name: Add SELinux port permission for nginx on port 8080
            # Настраиваем SELinux (привет предыдущей лабораторке )
            seport:
                ports: "{{ nginx_listen_port }}"
                proto: tcp
                setype: http_port_t
                state: present

            - name: Create custom nginx configuration from template
            # Разворачиваем конфигурацию из шаблона jinja2 с перемененными;
            template:
                src: [templates/nginx.conf.j2](./provisioning/templates/nginx.conf.j2)
                dest: "{{ nginx_conf_path }}"
                backup: yes
                mode: 0644
            notify:
                - Restart nginx service

            - name: Configure firewall to allow nginx port
            firewalld:
                port: "{{ nginx_listen_port }}/tcp"
                permanent: yes
                state: enabled
            notify:
                - Reload firewall

            - name: Create custom index.html
            copy:
                content: |
                <!DOCTYPE html>
                <html>
                <head>
                    <title>Nginx on Port {{ nginx_listen_port }}</title>
                </head>
                <body>
                    <h1>Welcome to Nginx!</h1>
                    <p>Server is listening on port {{ nginx_listen_port }}</p>
                    <p>This page was deployed by Ansible</p>
                    <p>SELinux configured for port {{ nginx_listen_port }}</p>
                </body>
                </html>
                dest: /usr/share/nginx/html/index.html
                mode: 0644
            notify:
                - Restart nginx service

        handlers:
            - name: Enable nginx service
            systemd:
                name: nginx
                enabled: yes

            - name: Start nginx service
            systemd:
                name: nginx
                state: started

            - name: Restart nginx service
            systemd:
                name: nginx
                state: restarted
                daemon_reload: yes

            - name: Reload firewall
            systemd:
                name: firewalld
                state: reloaded
