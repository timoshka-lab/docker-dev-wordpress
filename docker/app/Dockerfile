ARG PHP_VERSION=7.4
FROM php:${PHP_VERSION}-fpm-alpine

ENV TZ "Asia/Tokyo"
ENV COMPOSER_ALLOW_SUPERUSER 1

# Set timezone
RUN set -ex && \
    apk update && \
    apk upgrade && \
    apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apk del tzdata && \
    rm -rf /tmp/* /var/cache/apk/*

# Install dependency
RUN apk --update add \
    bash \
    git \
    zip \
    wget \
    zlib \
    zlib-dev \
    gcc \
    libjpeg \
    optipng \
    gifsicle \
    pngquant \
    libjpeg-turbo-utils && \
    rm -rf /tmp/* /var/cache/apk/*

# Install php extension manager
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && sync

# Install php extensions
RUN install-php-extensions \
    mysqli \
    pdo_mysql \
    opcache \
    calendar \
    exif \
    gd \
    imagick \
    zip \
    xdebug \
    intl

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Add setup script
COPY ./setup.sh /setup.sh