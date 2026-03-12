FROM php:8.3-fpm

RUN apt-get update && apt-get install -y nginx

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY app/index.php /var/www/html/index.php

WORKDIR /var/www/html

CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]