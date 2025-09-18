FROM php:8.2-fpm

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
        libmagickwand-dev \
        libicu-dev \
        libxslt1-dev \
        zlib1g-dev \
        libcurl4-openssl-dev \
        libpng-dev \
        libwebp-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpq-dev \
        unixodbc-dev \
        curl \
        gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Microsoft ODBC Driver for SQL Server (modern keyring-based repo config)
RUN set -eux; \
    mkdir -p /etc/apt/keyrings; \
    apt-get update; \
    apt-get install -y --no-install-recommends gnupg2 ca-certificates curl; \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg; \
    chmod 0644 /etc/apt/keyrings/microsoft.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/mssql-release.list; \
    apt-get update; \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 unixodbc-dev; \
    rm -rf /var/lib/apt/lists/*

# Install PHP extensions using mlocati/php-extension-installer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/install-php-extensions

RUN chmod +x /usr/bin/install-php-extensions \
    && sync \
    && install-php-extensions \
        bcmath \
        ds \
        exif \
        gd \
        intl \
        opcache \
        pcntl \
        pdo_sqlsrv \
        redis \
        sqlsrv \
        zip \
        imagick \
        ldap \
        mysqli \
        pdo_mysql

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
