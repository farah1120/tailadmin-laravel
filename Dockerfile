FROM php:8.1-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    curl \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    nodejs \
    npm

# Install PHP extensions yang WAJIB untuk Laravel
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Ambil Composer terbaru
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . .

# Hapus folder vendor dan file lock lama jika ada (untuk menghindari konflik)
RUN rm -rf vendor composer.lock

# Install dependencies dengan mengabaikan batasan platform (agar lebih aman)
RUN composer install --no-interaction --optimize-autoloader --no-dev --ignore-platform-reqs

# Build aset frontend
RUN npm install && npm run build

# Atur izin folder
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

EXPOSE 8090

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8090"]
