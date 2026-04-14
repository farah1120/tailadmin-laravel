FROM php:8.1-fpm

# Install dependencies sistem
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev \
    libzip-dev libcurl4-openssl-dev zip unzip git curl

# Install PHP extensions wajib
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip xml curl

# Ambil Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy semua file aplikasi
COPY . .

# Install dependencies PHP (Abaikan script agar tidak error)
RUN composer install --no-interaction --no-scripts --prefer-dist --ignore-platform-reqs

# Pastikan folder storage bisa ditulis
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

EXPOSE 8090

# Jalankan Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8090"]
