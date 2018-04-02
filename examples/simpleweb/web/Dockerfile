FROM php:7-apache
# COPY httpd.conf         /usr/local/apache2/conf/httpd.conf
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt  pdo_mysql

## COPY index.php 	/var/www/html/

