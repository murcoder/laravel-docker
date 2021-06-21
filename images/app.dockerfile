# Set master image
FROM php:8.0-fpm

# Set working directory
WORKDIR /var/www/

# Install system dependencies
RUN apt-get update && \
	apt-get install -y \
    sudo \
    vim \
    curl \
    git \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libxrender1 \
    wkhtmltopdf \
    xvfb

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install LDAP extension
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
RUN install-php-extensions ldap zip

# Install xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Add useful alias
RUN echo 'alias ll="ls -alF"' >> ~/.bashrc

# Setup composer
RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer
RUN apt-get update && apt-get install -y gnupg

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

# Change current user
USER www