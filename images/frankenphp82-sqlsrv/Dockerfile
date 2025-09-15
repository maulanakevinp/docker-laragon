FROM dunglas/frankenphp:php8.2.28

ENV ACCEPT_EULA=Y
ENV SERVER_NAME="http://"

# Step 1: Install dependencies
RUN apt-get update && apt-get install -y \
    gnupg2 \
    unixodbc-dev \
    curl \
    libmagickwand-dev \
    apt-transport-https \
    lsb-release \
    imagemagick \
    libldap2-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libwebp-dev \
    libzip-dev \
    git \
    nano \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Step 2: Tambah repo Microsoft SQL ODBC 18
RUN mkdir -p /usr/share/keyrings && \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg && \
    chmod 644 /usr/share/keyrings/microsoft-prod.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 && \
    rm -rf /var/lib/apt/lists/*

# Step 3: Install PHP Extensions
RUN pecl install sqlsrv pdo_sqlsrv imagick redis \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv imagick redis \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install pdo pdo_mysql mysqli ldap gd zip pcntl

# Step 4: Tambah Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Step 5: Kerja di /app
WORKDIR /app

COPY Caddyfile /etc/frankenphp/Caddyfile

# Copy php.ini-production to php.ini
RUN cp $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini

# Override upload_max_filesize and post_max_size
RUN echo "upload_max_filesize=100M" > $PHP_INI_DIR/conf.d/custom.ini && \
    echo "post_max_size=100M" >> $PHP_INI_DIR/conf.d/custom.ini && \
    echo "memory_limit=1024M" >> $PHP_INI_DIR/conf.d/custom.ini && \
    echo "max_execution_time=360" >> $PHP_INI_DIR/conf.d/custom.ini && \
    echo "max_input_time=360" >> $PHP_INI_DIR/conf.d/custom.ini && \
    echo "max_input_vars=5000000" >> $PHP_INI_DIR/conf.d/custom.ini && \
    echo "date.timezone=Asia/Jakarta" >> $PHP_INI_DIR/conf.d/custom.ini

RUN git config --global --add safe.directory /app
