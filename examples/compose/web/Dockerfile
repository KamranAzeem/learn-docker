FROM php:7-apache

# Note: php:7-apache is a debian based image.
# Note: mycrypt extension is not provided with the PHP source since 7.2.
#       Instead it is available through PECL. 
#       To install a PECL extension in docker, 
#          use `pecl install <packagename-version>` to download and compile it, 
#          then use `docker-php-ext-enable` to enable it:

RUN apt-get update && apt-get install -y \
      libmcrypt-dev \
      libfreetype6-dev \
      libjpeg-dev \
      libpng-dev \
    && a2enmod rewrite expires \
    && pecl install mcrypt-1.0.1 \
    && docker-php-ext-install gd mysqli opcache iconv \
    && docker-php-ext-configure gd \
       --with-freetype-dir=/usr/include/ \
       --with-jpeg-dir=/usr/include/ \
       --with-png-dir=/usr/include/ \
    && docker-php-ext-enable mcrypt mysqli

# Copy any custom apache configuration / virtualhost configuraiton file at this point.
# Put your apache config files in /etc/apache2/sites-enabled/
# Main httpd.conf file is located at: /usr/local/apache2/conf/httpd.conf

# Default document-root is /var/www/html
# Apache is run as uid 33
# Apache configurations are in /etc/apache2


COPY index.html /var/www/html/
COPY index.php 	/var/www/html/

