# official PHP 8.0
FROM php:8.1-apache

# required packages
RUN apt-get update && apt-get install -y \
    zlib1g-dev \
    libzip-dev \
    unzip \
    git \
    ffmpeg

RUN docker-php-ext-install zip

#working directory
WORKDIR /var/www/html

# Copy the laravel files
COPY . /var/www/html

RUN chown -R www-data:www-data /var/www/html
RUN chmod 777 -R /var/www/html/storage/

# Enable Apache modules
RUN a2enmod rewrite headers

# install php ext
RUN docker-php-ext-install pdo pdo_mysql

# composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Add the code to perform git pull with credentials
RUN git config --global --add safe.directory /var/www/html
RUN echo -e "machine <git-url> login <user/email> password <password>" > ~/.netrc
RUN chmod 600 ~/.netrc
RUN git -c http.sslVerify=false pull https://'user':'password'@repo.git --allow-unrelated-histories
# RUN git pull origin master --allow-unrelated-histories

# php.ini and apache files
# COPY php.ini /etc/php/
COPY .docker/conf/default-apache.conf /etc/apache2/sites-available/000-default.conf

# compy to site-enabled
# RUN ln -s /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/

# composer install
RUN rm -rf composer.lock
RUN composer install --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs

RUN composer dump-autoload

EXPOSE 80
