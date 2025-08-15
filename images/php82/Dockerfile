FROM php:8.2-fpm

ENV ACCEPT_EULA=Y

# Install prerequisites required for tools and extensions installed later on.
RUN apt-get update \
    && apt-get install -y apt-transport-https gnupg2 libpng-dev libzip-dev unzip \
    && rm -rf /var/lib/apt/lists/*

# Install prerequisites for the sqlsrv and pdo_sqlsrv PHP extensions.
RUN set -eux; \
    # Prepare APT keyring directory and ensure required tools are present
    mkdir -p /etc/apt/keyrings; \
    apt-get update; \
    apt-get install -y --no-install-recommends gnupg2 ca-certificates curl; \
    # Import Microsoft GPG key into keyring and add the correct repo for current Debian version
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg; \
    chmod 0644 /etc/apt/keyrings/microsoft.gpg; \
    # Pin to Debian 12 (bookworm) Microsoft repo since Debian 13 (trixie) is not yet supported
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/mssql-release.list; \
    apt-get update; \
    apt-get install -y msodbcsql18 mssql-tools18 unixodbc-dev; \
    rm -rf /var/lib/apt/lists/*

# Retrieve the script used to install PHP extensions from the source container.
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/install-php-extensions

# install composer 2 (signature-verified)
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

# Install required PHP extensions and all their prerequisites available via apt.
RUN chmod uga+x /usr/bin/install-php-extensions \
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
        ldap

# Setting the work directory.
WORKDIR /var/www