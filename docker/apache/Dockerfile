FROM php:8.2-apache

# Cài thêm các extension PHP + bật các module Apache
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev zip unzip apache2-utils \
    && docker-php-ext-install pdo_mysql \
    && a2enmod rewrite remoteip headers

# Copy file cấu hình VirtualHost
COPY /apache/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN ln -sf /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/000-default.conf
