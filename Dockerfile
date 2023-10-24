# Use the official PHP image with Apache
FROM php:8.0-apache

# Install git, unzip, and other necessary tools and PHP extensions
RUN apt-get update && apt-get install -y git unzip libpng-dev mariadb-client && \
    docker-php-ext-install pdo pdo_mysql gd

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Install Laravel and other PHP dependencies
RUN composer create-project laravel/laravel . && \
    composer require barryvdh/laravel-debugbar --dev && \
    composer require --dev barryvdh/laravel-ide-helper

# Install Breeze, Vue, TypeScript, Vite and other JavaScript dependencies
RUN php artisan breeze:install && \
    npm install vue@latest vue-router@4 typescript vite -g && \
    npm install

# Configure Laravel
COPY .env.example .env
RUN sed -i 's/DB_CONNECTION=mysql/DB_CONNECTION=mariadb/g' .env && \
    sed -i 's/DB_HOST=127.0.0.1/DB_HOST=mariadb/g' .env && \
    sed -i 's/DB_DATABASE=homestead/DB_DATABASE=prevention/g' .env && \
    php artisan key:generate

# Run migrations
RUN php artisan migrate

# Seed the database and create all necessary data
RUN php artisan create:all && \
    php artisan db:seed

# Expose necessary ports
EXPOSE 8000 5173

# Start the local server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
