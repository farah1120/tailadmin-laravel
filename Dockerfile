FROM php:8.1-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    g++ \
    nodejs \
    npm

# Clear cache untuk menghemat ruang
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd intl zip

WORKDIR /var/www

# Copy semua file ke dalam folder workdir
COPY . .

# Install dependencies via composer (pastikan composer tersedia atau gunakan install.sh jika isinya benar)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Jalankan npm untuk build assets
RUN npm install && npm run build

# Beri izin akses ke folder storage
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Port yang diekspos (sesuai permintaan lab port 8090)
EXPOSE 8090

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8090"]
