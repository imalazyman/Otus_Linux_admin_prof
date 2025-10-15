# Заметки на полях

## Схема стэнда

![shem](img/project.drawio.png)

    sudo dnf update -y
    sudo dnf install epel-release -y
    sudo dnf install ansible git vim python3 python3-pip -y
  
### Генерация и деплой ключей на сервера 
 
    ssh-keygen -t ed25519 -C "vagrant@master-srv"
  
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDCM3Xy/GdDT43tdNpMe5GRCqlmZcRmJZsARqFahF73R vagrant@master-srv" >> ~/.ssh/authorized_keys
  
### Порядок запуска playbooks для конфигурации серверов.

#### Настройка web-сервера

    ansible-playbook -i inventory.yml playbooks/tune_web.yml --limit web-srv

#### Настройка сервера мониторинга

    ansible-playbook -i inventory.yml playbooks/tune_mon.yml --limit mon-srv

#### Настройка серверов баз данных

    ansible-playbook -i inventory.yml playbooks/tune_db.yml --limit db-2-srv | db-2-srv
    ansible-playbook -i inventory.yml playbooks/mariadb-replication.yml

## Восстановление компонентов

### Запуск скрипта для листинга бэкапов
    sudo /usr/local/bin/list-backups.sh

### Пример запуска через скрипт
    sudo /usr/local/bin/restore.sh /opt/backups/mysql/20250928_020001/ db
    sudo /usr/local/bin/restore.sh /opt/backups/wordpress/20250928_020001/ web  
    sudo /usr/local/bin/restore.sh /opt/backups/monitoring/20250928_020001/ monitoring
    sudo /usr/local/bin/restore.sh /opt/backups/ full 20250928_020001

### Пример запуска через Ansible
    ansible-playbook playbooks/restore.yml -e "restore_component=db"
