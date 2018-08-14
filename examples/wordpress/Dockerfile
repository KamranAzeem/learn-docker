FROM php:7.2-apache

# Note: mycrypt extension is not provided with the PHP source since 7.2.
#       Instead it is available through PECL. 
#       To install a PECL extension in docker, 
#          use `pecl install <packagename-version>` to download and compile it, 
#          then use `docker-php-ext-enable` to enable it:

#       wordpress needs mod-rewrite enabled in apache, which is disabled in default php:7-apache image.

RUN    apt-get update \
    && apt-get install -y --no-install-recommends \
         libjpeg-dev \
         libpng-dev \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd mysqli opcache \
    && a2enmod rewrite expires \
    && curl -# -LO https://wordpress.org/latest.tar.gz \
    && tar xzf latest.tar.gz \
    && mv wordpress/* /var/www/html/ \
    && chown 33:33 /var/www/html -R



#######################################################################################
# Optional:
# Copy any custom apache configuration / virtualhost configuraiton file at this point.
# Put your apache config files in /etc/apache2/sites-enabled/
# Main httpd.conf file is located at: /usr/local/apache2/conf/httpd.conf
#######################################################################################


# Note: 
# * This image runs apache as uid 33 (www-data). So ensure that your DocumentRoot is writeable by this user.
# * Default document-root is /var/www/html

