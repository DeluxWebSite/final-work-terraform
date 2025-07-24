FROM serversideup/php:8.4-fpm-apache

USER root

RUN apt-get update

RUN docker-php-ext-install pdo

# RUN docker-php-ext-install pdo-mysql

RUN docker-php-ext-install mysqli

COPY ./src /var/www/html

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

RUN chown -R www-data:www-data /var/www/html/

EXPOSE 80

# USER www

ENTRYPOINT [“apachectl”, “-D”, “FOREGROUND”]

# CMD [“apachectl”, “-D”, “FOREGROUND”]