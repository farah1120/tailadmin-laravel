FROM php:8.1-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libcurl4-openssl-dev \
    zip \
    unzip \
    git \
    curl \
    nodejs \
    npm

# Install PHP extensions (Termasuk dom, xml, dan curl)
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip xml curl

# Ambil Composer terbaru
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . .

# Hapus cache dan install tanpa menjalankan script artisan
RUN composer clear-cache && \
    composer install --no-interaction --no-scripts --prefer-dist --optimize-autoloader

# Build assets frontend
RUN npm install && npm run build

# Atur izin folder
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

EXPOSE 8090
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8090"]
