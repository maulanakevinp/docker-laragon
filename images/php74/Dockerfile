FROM php:7.4-fpm

ENV ACCEPT_EULA=Y

# Install system dependencies
RUN apt-get update \
  && apt-get install -y \
    apt-transport-https \
    gnupg2 \
    libpng-dev \
    libzip-dev \
    unzip \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    libssl-dev \
    libldap2-dev \
    libicu-dev \
    libxslt1-dev \
    zlib1g-dev \
    libcurl4-openssl-dev \
    libwebp-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpq-dev \
    libsodium-dev \
    libffi-dev \
    curl \
    gnupg \
  && rm -rf /var/lib/apt/lists/*

# Install PHP extensions using mlocati/php-extension-installer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/install-php-extensions

RUN chmod +x /usr/bin/install-php-extensions \
  && sync \
  && install-php-extensions \
    calendar \
    exif \
    ffi \
    ftp \
    gd \
    gettext \
    intl \
    mysqli \
    opcache \
    pcntl \
    pdo_mysql \
    shmop \
    soap \
    sockets \
    sodium \
    sysvmsg \
    sysvsem \
    sysvshm \
    xsl \
    zip

# Install Composer (robust with signature verification)
RUN set -eux; \
  EXPECTED_SIGNATURE=$(curl -fsSL https://composer.github.io/installer.sig); \
  curl -fsSL https://getcomposer.org/installer -o /tmp/composer-setup.php; \
  ACTUAL_SIGNATURE=$(php -r "echo hash_file('sha384', '/tmp/composer-setup.php');"); \
  if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then \
    echo 'ERROR: Invalid Composer installer signature' >&2; \
    rm -f /tmp/composer-setup.php; \
    exit 1; \
  fi; \
  php /tmp/composer-setup.php --install-dir=/usr/bin --filename=composer; \
  rm -f /tmp/composer-setup.php

# Set working directory
WORKDIR /var/www
