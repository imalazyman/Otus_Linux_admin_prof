# Д.З. 9 Инициализация системы. Systemd.
1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/default).
2. Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта (https://gist.github.com/cea2k/1318020).
3. Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно.


Для выполнения используется Vagrant, [Vagrantfile](./Vagrantfile) прилагается.

## 1. Написать service...

Задаем пароль для root и в дальнейшем все действия выполняем под ним

		vagrant@sysd:~$ sudo passwd root
		New password:
		Retype new password:
		passwd: password updated successfully
		vagrant@sysd:~$ su -
		Password:

#### Конфигурирем сервис

создаём файл с конфигурацией для сервиса в директории /etc/default

		root@sysd:/vagrant# cat > /etc/default/log-monitor << 'END'
		# Конфигурационный файл для сервиса мониторинга логов
		LOG_FILE="/var/log/watchlog.log"
		KEYWORD="ALERT"
		END


Генерим лог-файл [watchlog.log](./watchlog.log)  и кладем его в папку /var/log

Создадим скрипт [log-monitor.sh ](./log-monitor.sh)

		root@sysd:/vagrant# cat > /usr/local/bin/log-monitor.sh << 'END'
		#!/bin/bash

		# Добавляем дату к строке вывода
		log_message() {
				logger "$(date '+%d.%m.%Y-%H:%M:%S') - $1"
		}

		# Проверим существование параметров
		if [ -z "$LOG_FILE" ] || [ -z "$KEYWORD" ]; then
				log_message "ОШИБКА: LOG_FILE или KEYWORD не заданы"
				exit 1
		fi

		# Проверим существования файла лога
		if [ ! -f "$LOG_FILE" ]; then
				log_message "ОШИБКА: Файл лога $LOG_FILE не найден"
				exit 1
		fi

		# Поиск ключевого слова
		matches=$(grep -c "$KEYWORD" "$LOG_FILE" 2>/dev/null)

		if [ "$matches" -gt 0 ]; then
				log_message "НАЙДЕНО: $matches вхождений ключевого слова '$KEYWORD' в $LOG_FILE"
				exit 0
		else
				log_message "Ключевое слово '$KEYWORD' не найдено"
				exit 0
		fi

		END



И добавляем права на запуск

		root@sysd:/vagrant# chmod +x /usr/local/bin/log-monitor.sh

Создадим юнит для сервиса [log-monitor.service ](./log-monitor.service):

		root@sysd:~# cat > /etc/systemd/system/log-monitor.service << 'END'
		[Unit]
		Description=Log Monitor Service
		After=network.target

		[Service]
		Type=oneshot
		User=root
		EnvironmentFile=/etc/default/log-monitor
		ExecStart=/usr/local/bin/log-monitor.sh

		# Настройки журналирования
		SyslogIdentifier=log-monitor
		SyslogFacility=local0
		SyslogLevel=info

		[Install]
		WantedBy=multi-user.target
		END

Создадим юнит для таймера [log-monitor.timer](./log-monitor.timer):

		root@sysd:~# cat > /etc/systemd/system/log-monitor.timer << 'END'
		[Unit]
		Description=Run log monitor every 30 seconds
		Requires=log-monitor.service

		[Timer]
		# Запускать каждые 30 секунд
		OnCalendar=*:*:0/30

		# Запускать через 30 секунд после загрузки системы
		OnBootSec=30s
		OnUnitActiveSec=30s

		# Настройки точности
		AccuracySec=1s

		[Install]
		WantedBy=timers.target
		END


#### Проверка работы

Перезагружаем демон systemd

	sudo systemctl daemon-reload

Включаем и запускаем таймер

	sudo systemctl enable log-monitor.timer
	sudo systemctl start log-monitor.timer

Проверяем статус таймера

		sudo systemctl status log-monitor.timer


Смотрим логи на предмет нужных нам сообщений

		tail -n 1000 /var/log/syslog  | grep слов

		Sep  1 12:00:30 ubuntu-jammy root: 01.09.2025-12:00:30 - НАЙДЕНО: 21 вхождений ключевого слова 'ALERT' в /var/log/watchlog.log
		Sep  1 12:01:00 ubuntu-jammy root: 01.09.2025-12:01:00 - НАЙДЕНО: 21 вхождений ключевого слова 'ALERT' в /var/log/watchlog.log
		Sep  1 12:01:30 ubuntu-jammy root: 01.09.2025-12:01:30 - НАЙДЕНО: 21 вхождений ключевого слова 'ALERT' в /var/log/watchlog.log
		Sep  1 12:02:00 ubuntu-jammy root: 01.09.2025-12:02:00 - НАЙДЕНО: 21 вхождений ключевого слова 'ALERT' в /var/log/watchlog.log
		Sep  1 12:02:30 ubuntu-jammy root: 01.09.2025-12:02:30 - НАЙДЕНО: 21 вхождений ключевого слова 'ALERT' в /var/log/watchlog.log
		Sep  1 12:03:00 ubuntu-jammy root: 01.09.2025-12:03:00 - НАЙДЕНО: 21 вхождений ключевого слова 'ALERT' в /var/log/watchlog.log
		Sep  1 12:03:30 ubuntu-jammy root: 01.09.2025-12:03:30 - НАЙДЕНО: 21 вхождений ключевого слова 'ALERT' в /var/log/watchlog.log
		Sep  1 12:04:00 ubuntu-jammy root: 01.09.2025-12:04:00 - НАЙДЕНО:

## 2. Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта.

spawn-fcgi и зависимости предустановлены с помощью [Vagrant](./Vagrantfile)

создаем файл настроек для сервиса.

		root@sysd:~# mkdir /etc/spawn-fcgi/
		root@sysd:~# cat > /etc/spawn-fcgi/fcgi.conf << 'END'
		SOCKET=/var/run/php-fcgi.sock
		OPTIONS="-u www-data -g www-data -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"
		END

Создаем юнит-файл

		root@sysd:~# cat > /etc/systemd/system/spawn-fcgi.service << 'END'
		[Unit]
		Description=Spawn-fcgi startup service by Otus
		After=network.target

		[Service]
		Type=simple
		PIDFile=/var/run/spawn-fcgi.pid
		EnvironmentFile=/etc/spawn-fcgi/fcgi.conf
		ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
		KillMode=process

		[Install]
		WantedBy=multi-user.target
		END


## 3. Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно

nginx предустановлен с помощью [Vagrant](./Vagrantfile)
Во избежание конфликтовостановим и отключем apache.

		root@sysd:~# systemctl disable apache2

После чего, запустим nginx

		root@sysd:~# systemctl start nginx
		root@sysd:~# systemctl status nginx
		● nginx.service - A high performance web server and a reverse proxy server
			Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
			Active: active (running) since Wed 2025-09-03 04:48:52 UTC; 1s ago
			Docs: man:nginx(8)
			Process: 2458 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
			Process: 2459 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
		Main PID: 2460 (nginx)
			Tasks: 3 (limit: 1101)
			Memory: 5.1M
				CPU: 21ms
			CGroup: /system.slice/nginx.service
					├─2460 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
					├─2461 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""
					└─2462 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""

		Sep 03 04:48:52 sysd systemd[1]: Starting A high performance web server and a reverse proxy server...
		Sep 03 04:48:52 sysd systemd[1]: Started A high performance web server and a reverse proxy server.


Посмотрим оригинальный файл юнита nginx

		root@sysd:~# cat /lib/systemd/system/nginx.service
		# Stop dance for nginx
		# =======================
		#
		# ExecStop sends SIGSTOP (graceful stop) to the nginx process.
		# If, after 5s (--retry QUIT/5) nginx is still running, systemd takes control
		# and sends SIGTERM (fast shutdown) to the main process.
		# After another 5s (TimeoutStopSec=5), and if nginx is alive, systemd sends
		# SIGKILL to all the remaining processes in the process group (KillMode=mixed).
		#
		# nginx signals reference doc:
		# http://nginx.org/en/docs/control.html
		#
		[Unit]
		Description=A high performance web server and a reverse proxy server
		Documentation=man:nginx(8)
		After=network.target nss-lookup.target

		[Service]
		Type=forking
		PIDFile=/run/nginx.pid
		ExecStartPre=/usr/sbin/nginx -t -q -g 'daemon on; master_process on;'
		ExecStart=/usr/sbin/nginx -g 'daemon on; master_process on;'
		ExecReload=/usr/sbin/nginx -g 'daemon on; master_process on;' -s reload
		ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx.pid
		TimeoutStopSec=5
		KillMode=mixed

		[Install]
		WantedBy=multi-user.target

Для запуска нескольких экземпляров nginx создадим новый юнит, который будет работать с шаблонами.

		root@sysd:~#cat > /etc/systemd/system/nginx@.service << 'END'
		[Unit]
		Description=Mod high performance web server and a reverse proxy server
		After=network.target nss-lookup.target

		[Service]
		Type=forking
		PIDFile=/run/nginx-%I.pid
		ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-%I.conf -q -g 'daemon on; master_process on;'
		ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;'
		ExecReload=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;' -s reload
		ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx-%I.pid
		TimeoutStopSec=5
		KillMode=mixed

		[Install]
		WantedBy=multi-user.target
		END

Под каждый сервис создаем файл конфигурации путем изменения стандартного. Файл по умолчанию имеет вид:

		user www-data;
		worker_processes auto;
		pid /run/nginx.pid;
		include /etc/nginx/modules-enabled/*.conf;

		events {
				worker_connections 768;
				# multi_accept on;
		}

		http {

				##
				# Basic Settings
				##

				sendfile on;
				tcp_nopush on;
				types_hash_max_size 2048;
				# server_tokens off;

				# server_names_hash_bucket_size 64;
				# server_name_in_redirect off;

				include /etc/nginx/mime.types;
				default_type application/octet-stream;

				##
				# SSL Settings
				##

				ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
				ssl_prefer_server_ciphers on;

				##
				# Logging Settings
				##

				access_log /var/log/nginx/access.log;
				error_log /var/log/nginx/error.log;

				##
				# Gzip Settings
				##

				gzip on;

				# gzip_vary on;
				# gzip_proxied any;
				# gzip_comp_level 6;
				# gzip_buffers 16 8k;
				# gzip_http_version 1.1;
				# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

				##
				# Virtual Host Configs
				##

				include /etc/nginx/conf.d/*.conf;
				include /etc/nginx/sites-enabled/*;
		}


		#mail {
		#       # See sample authentication script at:
		#       # http://wiki.nginx.org/ImapAuthenticateWithApachePhpScript
		#
		#       # auth_http localhost/auth.php;
		#       # pop3_capabilities "TOP" "USER";
		#       # imap_capabilities "IMAP4rev1" "UIDPLUS";
		#
		#       server {
		#               listen     localhost:110;
		#               protocol   pop3;
		#               proxy      on;
		#       }
		#
		#       server {
		#               listen     localhost:143;
		#               protocol   imap;
		#               proxy      on;
		#       }
		#}

Изменим строчки с путями файлов до PID

		pid /run/nginx.pid;

Меняем на:

		pid /run/nginx-first.pid;

Для первого процесса и на:

		pid /run/nginx-second.pid;

для второго. Так же закомментируем подключение файлов конфигурации дополнительных сайтов

		#include /etc/nginx/sites-enabled/*;

И меняем порты в секции http на первом сервисе:

		http {
		…
		server {
			listen 9001;
			}
		}


для первого процесса и на:

		http {
		…
		server {
			listen 9002;
			}
		}

для второго.

полученые файлы [nginx-first.conf](./nginx-first.conf) и [nginx-second.conf](./nginx-second.conf) поместим в папку /etc/nginx/ и проверим работу сервисов

		root@sysd:~# systemctl start nginx@first
		root@sysd:~# systemctl start nginx@second
		root@sysd:~# ss -tnulp | grep nginx
		tcp   LISTEN 0      511             0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=2462,fd=6),("nginx",pid=2461,fd=6),("nginx",pid=2460,fd=6))
		tcp   LISTEN 0      511             0.0.0.0:9001      0.0.0.0:*    users:(("nginx",pid=3383,fd=6),("nginx",pid=3382,fd=6),("nginx",pid=3381,fd=6))
		tcp   LISTEN 0      511             0.0.0.0:9002      0.0.0.0:*    users:(("nginx",pid=3390,fd=6),("nginx",pid=3389,fd=6),("nginx",pid=3388,fd=6))
		tcp   LISTEN 0      511                [::]:80           [::]:*    users:(("nginx",pid=2462,fd=7),("nginx",pid=2461,fd=7),("nginx",pid=2460,fd=7))
		root@sysd:~#
		root@sysd:~# ps afx | grep nginx
		3408 pts/0    S+     0:00                      \_ grep --color=auto nginx
		2460 ?        Ss     0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
		2461 ?        S      0:00  \_ nginx: worker process
		2462 ?        S      0:00  \_ nginx: worker process
		3381 ?        Ss     0:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-first.conf -g daemon on; master_process on;
		3382 ?        S      0:00  \_ nginx: worker process
		3383 ?        S      0:00  \_ nginx: worker process
		3388 ?        Ss     0:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-second.conf -g daemon on; master_process on;
		3389 ?        S      0:00  \_ nginx: worker process
		3390 ?        S      0:00  \_ nginx: worker process
		root@sysd:~#

Как видно стартованы 3 сервиса - основной и два дополнительных.