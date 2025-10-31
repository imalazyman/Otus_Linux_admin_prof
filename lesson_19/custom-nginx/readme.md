# Домашнее задание №19 по теме Docker

### Задание: Освоить базовые принципы работы с Docker, научиться создавать, настраивать и управлять контейнерами

1. Установите Docker на хост машину
2. Установите Docker Compose - как плагин, или как отдельное приложение
3. Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx)
4. Определите разницу между контейнером и образом. Вывод опишите в домашнем задании.
5. Ответьте на вопрос: Можно ли в контейнере собрать ядро?



### 1. Установка Docker

для задания используется рабочая станция с РедОС 8.0.2

        # dnf install docker-ce docker-ce-cli

### 2. Установите Docker Compose - как плагин, или как отдельное приложение

как плагин в РедОC Docker-compose не ставится, устанавливаю как отдельное приложение

        # dnf install docker-compose
        
### 3. Создайте свой кастомный образ nginx на базе alpine.

Создаем структуру проекта:

       # mkdir custom-nginx && cd custom-nginx

Dockerfile:

        FROM nginx:alpine

        # Копируем кастомную страницу
        COPY index.html /usr/share/nginx/html/index.html

        # Экспонируем порт
        EXPOSE 80

        # Команда для запуска nginx
        CMD ["nginx", "-g", "daemon off;"]

index.html:

        <!DOCTYPE html>
        <html>
        <head>
            <title>Custom Nginx Page</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    margin: 40px;
                    background-color: #f0f8ff;
                }
                .container {
                    max-width: 800px;
                    margin: 0 auto;
                    padding: 20px;
                    background-color: white;
                    border-radius: 10px;
                    box-shadow: 0 0 10px rgba(0,0,0,0.1);
                }
                h1 {
                    color: #2c3e50;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Welcome to Custom Nginx!</h1>
                <p>This is a custom Nginx page running on Alpine Linux</p>
                <p><strong>Student:</strong> Your Name</p>
                <p><strong>Date:</strong> $(date)</p>
                <p>This container was built from a custom Docker image</p>
            </div>
        </body>
        </html>

Сборка образа и запуск контейнера:

        # docker build -t my-custom-nginx:alpine .
        # docker run -d -p 8080:80 --name custom-nginx-container my-custom-nginx:alpine

Проверка:

curl http://localhost:8080

Пуш образа в Docker Hub

        # docker tag my-custom-nginx:alpine imaleo/otus_linux_admin_prof:nginx_alpine
        # docker push imaleo/otus_linux_admin_prof:nginx_alpine


ссылка на репозиторий: https://hub.docker.com/r/imaleo/otus_linux_admin_prof/tags

### 4. Определите разницу между контейнером и образом.

##### Образ (Image):

Шаблон или шаблон только для чтения с инструкциями для создания контейнера. Состоит из слоев файловой системы. Неизменяемый. Хранится в репозитории (Docker Hub, private registry).Создается с помощью Dockerfile

##### Контейнер (Container):

Запущенный экземпляр образа. Имеет "изменяемый" слой поверх образа. Изолированная среда выполнения. Может быть запущен, остановлен, удален. Имеет состояние (running, stopped, exited).

### 5. Можно ли в контейнере собрать ядро?

- Технически - да, но с серьезными ограничениями:
- Возможно собрать, но нельзя установить/загрузить новое ядро из контейнера
- Требуются привилегии: необходимо использовать --privileged флаг

Ограничения:

- Собранное ядро будет доступно только внутри контейнера
- Нельзя заменить ядро хостовой системы
- Отсутствует доступ к загрузчику (GRUB)
- Практическое применение: в основном для тестирования и разработки
