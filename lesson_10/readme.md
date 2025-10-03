# Д.З. 10 Написать скрипт на языке Bash;


## Описание
Написать скрипт для CRON, который раз в час будет формировать письмо и отправлять на заданную почту.

Необходимая информация в письме:

Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
Ошибки веб-сервера/приложения c момента последнего запуска;
Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта.
Скрипт должен предотвращать одновременный запуск нескольких копий, до его завершения.

В письме должен быть прописан обрабатываемый временной диапазон.

Прилагается [log-файл](./access-4560-644067.log), который надо обработать.
Для выполнения используется Vagrant, [Vagrantfile](./Vagrantfile) прилагается. В файле устанавливаются необходиые пакеты для работы с почтой, настраивается FQDN сервера и копируются в виртуальную машину файлы [лога](./access-4560-644067.log) и сам [скрипт](./analize.sh).

### Создаем скрипт
Определим переменные

        LOG_FILE="/home/vagrant/access.log"        # Путь к логу
        LOCK_FILE="/tmp/file.lock"                 # Файл блокировки
        LAST_RUN_FILE="/tmp/file_timestamp"        # Файл для хранения времени последнего запуска

Определим способ, которым будем проверять запущен ли скрипт в настоящее время - это существование файла "блокировки", он будес создаваться в момент запуска скрипта и удаляться при его завершении. В скрипте будем проверять сущесвование этого файла.

        if [ -f "$LOCK_FILE" ]; then
            echo "В настоящее время скрипт уже выполняется."
            exit 1
        else
            touch "$LOCK_FILE"  # Создаем файл блокировки, чтобы предотвратить одновременный запуск
        fi

Чтобы работать с временными интервалами получим текущее время и сохраним его в файл file_timestamp

        CURRENT_TIME=$(date +%s)
        echo "$CURRENT_TIME" > "$LAST_RUN_FILE" # Сохраняем текущее время

Если наш скрипт запускается в первый раз, то установим время последнего запуска на 0, если существует, то возьмем его из файла, созданного в предыдущем пункте.

        if [ ! -f "$LAST_RUN_FILE" ]; then
            LAST_RUN_TIMESTAMP=0
        else
            LAST_RUN_TIMESTAMP=$(cat "$LAST_RUN_FILE")
        fi

Преобразуем время последнего запуска в формат для grep
        
        START_TIME=$(date -d @$LAST_RUN_TIMESTAMP "+%d.%b.%Y:%H:%M:%S")

Начнем формировать тело письма. 

        REPORT="Отчет о запросах с последнего запуска скрипта ($START_TIME):\n\n"

Выведем 15 наиболее часто встречающихся ip-адресов. Поле с ip-аресом в логе идет первым, поэтому выберем его awk '{print $1}'

        REPORT+="\nСписок IP-адресов с наибольшим количеством запросов:\n"
        TOP_IPS=$(grep -E "^\S+.*" $LOG_FILE | awk '{print $1}' | sort | uniq -c | sort -rn | head -n 15)
        REPORT+="$TOP_IPS\n"

Далее выберем 15 самых запрашиваемых URLs. По анлогии выбираем 7 поле содержащее адрес сайта.

        REPORT+="\nСписок запрашиваемых URL:\n"
        TOP_URLS=$(grep -E "^\S+.*" $LOG_FILE | awk '{print $7}' | sort | uniq -c | sort -rn | head -n 15)
        REPORT+="$TOP_URLS\n"


Следующим пунктом выберем самые часто встречающиеся ошибки, коды ошибок - 403,404,500,502,503

        REPORT+="\nОшибки веб-сервера:\n"
        ERRORS=$(grep -E "^\S+.*" $LOG_FILE | grep -E ' 403| 404| 500| 502| 503' | awk '{print $9}' | sort | uniq -c | sort -rn)
        REPORT+="$ERRORS\n"

Выбираем все коды ответа веб сервера

        REPORT+="\nВсе коды HTTP ответа:\n"
        HTTP_CODES=$(grep -E "^\S+.*" $LOG_FILE | awk {'print $9'} | grep -E '[0-9][0-9][0-9]' | sort | uniq -c | sort -rn)
        REPORT+="$HTTP_CODES\n"

Теперь переменную REPORT запишем в файл report.txt 
        
        echo -e "$REPORT" > report.txt

И отправим на почту

        echo "$REPORT" | mail -s "Log_Report" vagrant@localhost

После чего удалим файл блокировки

        rm -f "$LOCK_FILE"

Запустим скрипт

        [vagrant@bashlog ~]$ ./analize.sh

И проверм почту

        [vagrant@bashlog ~]$ mail
        s-nail version v14.9.22.  Type `?' for help
        /var/spool/mail/vagrant: 1 message 1 unread
        ▸U  1 vagrant@bashlog.loca  2025-09-06 16:43   61/2243  "Log_Report                                                    "
        & exit
        [vagrant@bashlog ~]$

Как видно в почтовом ящике пользователя vagrant, появилось письмо. Посмотрим его.

        [vagrant@bashlog ~]$ mail
        s-nail version v14.9.22.  Type `?' for help
        /var/spool/mail/vagrant: 2 messages 1 new 2 unread
        U  1 vagrant@bashlog.loca  2025-09-06 16:43   61/2243  "Log_Report                                                    "
        &
        [-- Message  1 -- 60 lines, 2233 bytes --]:
        From: vagrant@bashlog.localdomain
        Message-Id: <202509061919.586JJpRj005085@bashlog.localdomain>
        Date: Sat, 06 Sep 2025 19:19:51 +0000
        To: vagrant@bashlog.localdomain
        Subject: Log_Report

        Отчет о запросах с последнего запуска скрипта (06.Sep.2025:19:19:51):\n\n\nСписок IP-адресов с наибольшим количеством за
        просов:\n     45 93.158.167.130
            39 109.236.252.130
            37 212.57.117.19
            33 188.43.241.106
            31 87.250.233.68
            24 62.75.198.172
            22 148.251.223.21
            20 185.6.8.9
            17 217.118.66.161
            16 95.165.18.146
            12 95.108.181.93
            12 62.210.252.196
            12 185.142.236.35
            12 162.243.13.195
            8 163.179.32.118\n\nСписок запрашиваемых URL:\n    157 /
            120 /wp-login.php
            57 /xmlrpc.php
            26 /robots.txt
            12 /favicon.ico
            11 400
            9 /wp-includes/js/wp-embed.min.js?ver=5.0.4
            7 /wp-admin/admin-post.php?page=301bulkoptions
            7 /1
            6 /wp-content/uploads/2016/10/robo5.jpg
            6 /wp-content/uploads/2016/10/robo4.jpg
            6 /wp-content/uploads/2016/10/robo3.jpg
            6 /wp-content/uploads/2016/10/robo2.jpg
            6 /wp-content/uploads/2016/10/robo1.jpg
            6 /wp-content/uploads/2016/10/aoc-1.jpg\n\nОшибки веб-сервера:\n     51 404
            3 500
            1 403\n\nВсе коды HTTP ответа:\n    498 200
            95 301
            51 404
            7 400
            3 500
            2 499
            1 405
            1 403
            1 304\n

        & exit
        You have mail in /var/spool/mail/vagrant

Теперь редактируем crontab
        
        crontab -e

И добавляем строку (выполнять в 0 минут каждого часа)

        0 * * * * /home/vagrant/analize.sh 

### Конец