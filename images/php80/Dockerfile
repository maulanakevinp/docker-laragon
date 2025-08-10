FROM php:8.0-fpm

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

# Install Microsoft ODBC Driver for SQL Server
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

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

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Set working directory
WORKDIR /var/www
