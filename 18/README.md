# Lesson 18

## Задание

- Написать Dockerfile на базе apache/nginx который будет содержать две статичные web-страницы
на разных портах. Например, 8080 и 3000.
- Пробросить эти порты на хост машину. Обе страницы должны быть доступны по адресам
localhost:8080 и localhost:3000
- Добавить 2 вольюма. Один для логов приложений, другой для web-страниц.

## Выполнение

Скачать репозиторий и перейти в каталог с Dockerfile

```
git clone https://github.com/greenlama/otus-linux.git && cd otus-linux/18
```

Создать Docker образ

```
docker build -t otus .
```

Запустить Docker контейнер

```
docker run -it --name nginx -v $(pwd)/files/www:/usr/share/nginx/html -v $(pwd)/files/logs:/var/log/nginx --rm -p 8080:8080 -p 3000:3000 -d otus
```
