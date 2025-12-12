FROM debian:bookworm-slim

# Install PHP-FPM + required extensions for WordPress
RUN apt update && apt install -y \
    php-fpm \
    php-mysql \
    php-xml \
    php-gd \
    php-curl \
    php-zip \
    php-mbstring \
    php-intl \
    php-soap \
    php-cli \
    wget \
    bash \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download WordPress
RUN mkdir -p /var/www/html && \
    wget -q https://wordpress.org/latest.tar.gz -O /tmp/wp.tar.gz && \
    tar -xzf /tmp/wp.tar.gz -C /var/www/html --strip-components=1 && \
    rm /tmp/wp.tar.gz

# Ownership for php-fpm user
RUN chown -R www-data:www-data /var/www/html

VOLUME ["/var/www/html"]

EXPOSE 9000

CMD ["php-fpm8.2", "-F"]
