FROM php:7.4-apache

# Update and install required packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Enable mod_rewrite for Apache (useful for API routing)
RUN a2enmod rewrite

# Set proper permissions for Apache
RUN chown -R www-data:www-data /var/www/html

# Copy custom Apache config
COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf

# Copy backend files into container
COPY ./ /var/www/html/

# Set working directory
WORKDIR /var/www/html

# Install PHP dependencies via Composer
RUN if [ -f composer.json ]; then composer install --no-interaction --no-dev --prefer-dist; fi

# Create offline directories for mail and tokens
RUN mkdir -p /var/www/html/offline_emails && \
    mkdir -p /var/www/html/offline_tokens && \
    mkdir -p /var/www/html/config && \
    chown -R www-data:www-data /var/www/html/offline_emails && \
    chown -R www-data:www-data /var/www/html/offline_tokens && \
    chmod 755 /var/www/html/offline_emails && \
    chmod 755 /var/www/html/offline_tokens

# Expose Apache port
EXPOSE 80

# Health check
HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
    CMD curl -f http://localhost/connect.php || exit 1

# Start Apache in foreground
CMD ["apache2-foreground"]