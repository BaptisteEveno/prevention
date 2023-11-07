# Use the official PHP image with the Apache server
FROM php:8.2-apache

# Install system dependencies including unzip, git, and zip extension for PHP
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    default-mysql-client \
    unzip \
    git \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set Composer to run as super user
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN git clone https://github.com/docker/docker-nodejs-sample
# Install Node.js and npm
# Install Node.js and npm


# Set working directory
WORKDIR /var/www/html

# Copy existing application directory contents
COPY . .

# Copy the .env file and configure database access
COPY .env.example .env
RUN sed -i 's/DB_CONNECTION=mysql/DB_CONNECTION=mysql\nDB_HOST=db\nDB_PORT=3306\nDB_DATABASE=prevention\nDB_USERNAME=root\nDB_PASSWORD=/' .env

# Install PHP dependencies
RUN composer install --no-interaction --no-plugins --no-scripts

# Generate application key
RUN php artisan key:generate

# Expose port 8000 and start PHP server
EXPOSE 8199
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8199"]
