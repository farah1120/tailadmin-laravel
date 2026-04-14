FROM php:8.1-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev \
    libzip-dev libcurl4-openssl-dev zip unzip git curl

# Install Node.js (Gunakan versi 18 agar lebih stabil dengan Laravel 9/10)
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip xml curl

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . .

# Install Composer dependencies (Skip scripts untuk keamanan)
RUN composer install --no-interaction --no-scripts --prefer-dist --ignore-platform-reqs

# Install NPM dengan flag --legacy-peer-deps (Untuk menghindari konflik versi library)
RUN npm install --legacy-peer-deps && npm run build

# Atur izin folder
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

EXPOSE 8090
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8090"]
