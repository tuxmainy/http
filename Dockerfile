FROM php:7-apache

ENV DEBIAN_FRONTEND noninterative

# Tools
RUN apt-get update && apt-get install -y libxml2-utils git

# Apache Modules
RUN a2enmod rewrite dav dav_fs dav_lock headers

# Apache Config
COPY conf/zz_prod.conf /etc/apache2/conf-available
RUN a2enconf zz_prod

# PHP Modules
## opcache
RUN docker-php-ext-configure opcache && docker-php-ext-install -j$(nproc) opcache

## pgsql
RUN apt-get update && apt-get install -y libpq-dev && docker-php-ext-configure pgsql && docker-php-ext-install pgsql

## zip
RUN apt-get update && apt-get install -y libzip-dev && docker-php-ext-configure zip && docker-php-ext-install zip

# composer
RUN curl https://getcomposer.org/installer --output /tmp/composer-setup.php && php /tmp/composer-setup.php --install-dir=/tmp && mv /tmp/composer.phar /usr/local/bin/composer

# cleanup
RUN rm -rf /var/lib/apt/lists/* /tmp/composer-setup.php

# PHP ini
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY ini/prod.ini /usr/local/etc/php/conf.d
COPY ini/opcache.ini /usr/local/etc/php/conf.d
