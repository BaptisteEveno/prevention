# Use a base image with PHP and composer pre-installed
FROM composer:latest as composer

# Set working directory
WORKDIR /app

# Copy application code to the container
COPY . /app

# Install composer dependencies
RUN composer install

# Use a base image with PHP and necessary extensions
FROM php:7.4-fpm

# Install MySQL extension for PHP
RUN docker-php-ext-install pdo_mysql

# Install NodeJS and npm
RUN apt-get update && apt-get install -y nodejs npm

# Copy installed dependencies from composer container
COPY --from=composer /app /app

# Set working directory
WORKDIR /app

# Copy over the environment file and set database configurations
RUN echo "DB_CONNECTION=mysql\n\
DB_HOST=127.0.0.1\n\
DB_PORT=3306\n\
DB_DATABASE=prevention\n\
DB_USERNAME=root\n\
DB_PASSWORD=" > .env

# The SQL command would be run from a MySQL/MariaDB client, so it's not included here

# Run the migrations, seed the database, and other necessary commands
RUN php artisan migrate && \
    php artisan create:all && \
    php artisan db:seed && \
    php artisan key:generate

# Install Vite globally
RUN npm install -g vite

# Run the project in development mode
RUN npm run dev

# Expose port 8000 for the server
EXPOSE 8000

# Start the local server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
