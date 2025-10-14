# Д.З. 15 Практика с SELinux

## 1. Запустить nginx на нестандартном порту 3-мя разными способами:
- переключатели setsebool;
- добавление нестандартного порта в имеющийся тип;
- формирование и установка модуля SELinux.

#### 1.1 Запуск с использованием setsebool;

Используем стенд из репозитария: https://github.com/Nickmob/vagrant_selinux 

После запуска виртуальной мащины проверяем состояние nginx на порту 4881

       $ sudo ss -tlpn | grep 4881

Пустая строка показывает что порт не используется.
Смотрим файл audit.log на предмет наличия записей сожержащих информацию об nginx на порту 4881

        $ sudo grep nginx /var/log/audit/audit.log | grep 4881
        type=AVC msg=audit(1760458486.306:807): avc:  denied  { name_bind } for  pid=7415 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

Проверяем конфигурацию nginx

        # nginx -t
        nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
        nginx: configuration file /etc/nginx/nginx.conf test is successful

Передадим информацию из лога в утилиту audit2why

        # grep nginx /var/log/audit/audit.log | grep 4881 | audit2why
        type=AVC msg=audit(1760458486.306:807): avc:  denied  { name_bind } for  pid=7415 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

        Was caused by:
        The boolean nis_enabled was set incorrectly.
        Description:
        Allow nis to enabled

        Allow access by executing:
        # setsebool -P nis_enabled 1

Утилита предлагает как решение установить параметр nis_enabled в 1. Пробуем. И пробуем запустить nginx.
        
        # setsebool -P nis_enabled 1
        # systemctl start nginx
        # systemctl status nginx
        ● nginx.service - The nginx HTTP and reverse proxy server
            Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
            Active: active (running) since Tue 2025-10-14 16:34:23 UTC; 8s ago
            Process: 10736 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
            Process: 10737 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
            Process: 10738 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
        Main PID: 10740 (nginx)
        ............

        # ss -tlpn | grep 4881
        LISTEN 0      511          0.0.0.0:4881      0.0.0.0:*    users:(("nginx",pid=10742,fd=6),("nginx",pid=10741,fd=6),("nginx",pid=10740,fd=6))
        LISTEN 0      511             [::]:4881         [::]:*    users:(("nginx",pid=10742,fd=7),("nginx",pid=10741,fd=7),("nginx",pid=10740,fd=7))

Как видно, nginx запущен на порту 4881.
Вернем значение nis_enabled обратно и остановим nginx
        
        # setsebool -P nis_enabled 0
        # systemctl restart nginx
        Job for nginx.service failed because the control process exited with error code.
        See "systemctl status nginx.service" and "journalctl -xeu nginx.service" for details.


#### 1.2 Запуск с помощью добавления нестандартного порта в имеющийся тип;

Мы сообщаем SELinux, что наш нестандартный порт (4881) — это такой же веб-порт, как и стандартные 80, 443. Мы добавляем его в тот же контекст http_port_t

        # semanage port -l | grep http_port_t
        http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
        pegasus_http_port_t            tcp      5988
        # semanage port -a -t http_port_t -p tcp 4881

Пробуем запустить nginx и проверить нужный порт

        # systemctl restart nginx
        # ss -tlpn | grep 4881
        LISTEN 0      511             [::]:4881         [::]:*    users:(("nginx",pid=10801,fd=7),("nginx",pid=10800,fd=7),("nginx",pid=10799,fd=7))
        LISTEN 0      511          0.0.0.0:4881      0.0.0.0:*    users:(("nginx",pid=10801,fd=6),("nginx",pid=10800,fd=6),("nginx",pid=10799,fd=6))

Снова возвращаем все в исходное состояние и останавливаем nginx

        # semanage port -d -t http_port_t -p tcp 4881
        # systemctl restart nginx
        Job for nginx.service failed because the control process exited with error code.
        See "systemctl status nginx.service" and "journalctl -xeu nginx.service" for details.


#### 1.3 Формирование и установка модуля SELinux (audit2allow);

Используем утилиту audit2allow, чтобы проанализировать лог и сгенерировать готовый модуль политики, который разрешит именно то действие, которое было запрещено.

        # grep nginx /var/log/audit/audit.log | grep denied | audit2allow -M mynginx
        ******************** IMPORTANT ***********************
        To make this policy package active, execute:

        semodule -i mynginx.pp

        [root@selinux ~]# ll
        total 8
        -rw-r--r--. 1 root root 962 Oct 14 17:21 mynginx.pp
        -rw-r--r--. 1 root root 259 Oct 14 17:21 mynginx.te

Созданы два файла: mynginx.te (исходник) и mynginx.pp (скомпилированный модуль).
Установливаем сгенерированный модуль:

        # semodule -i mynginx.pp

И пробуем запустить nginx

        # systemctl restart nginx
        # ss -tlpn | grep 4881
        LISTEN 0      511          0.0.0.0:4881      0.0.0.0:*    users:(("nginx",pid=10945,fd=6),("nginx",pid=10944,fd=6),("nginx",pid=10943,fd=6))
        LISTEN 0      511             [::]:4881         [::]:*    users:(("nginx",pid=10945,fd=7),("nginx",pid=10944,fd=7),("nginx",pid=10943,fd=7))

## 2. Обеспечить работоспособность приложения при включенном selinux.
- развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems;
- выяснить причину неработоспособности механизма обновления зоны (см. README);
- предложить решение (или решения) для данной проблемы;
- выбрать одно из решений для реализации, предварительно обосновав выбор;
- реализовать выбранное решение и продемонстрировать его работоспособность.

