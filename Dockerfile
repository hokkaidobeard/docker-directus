FROM php:apache
MAINTAINER Maik Hummel <m@ikhummel.com>

WORKDIR /var/www/html

COPY init.sh /opt/

ENV ADMIN_EMAIL=admin@localhost \
    SITE_NAME=Directus \
    ADMIN_PASSWORD=Un1c0rn

RUN apt-get update && apt-get install -yq git \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev && \
    apt-get install -yq libmagickwand-dev --no-install-recommends && \
    docker-php-ext-install iconv mcrypt && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd mysqli pdo pdo_mysql && \
    pecl install imagick-beta && \
    docker-php-ext-enable imagick && \
    
    curl -sL 'https://github.com/RNGR/Directus/tarball/master' | tar xz -C . --strip-components=1 && \
    cd api && curl -sL 'https://getcomposer.org/installer' | php && \
    php composer.phar install --no-dev && \
    chown -R www-data:www-data /var/www/html && \
    a2enmod rewrite && \

    chmod +x /opt/init.sh && \
    
    # clean up
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean

COPY init.php /var/www/html/installation

CMD /opt/init.sh
