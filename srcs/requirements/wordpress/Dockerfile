# Base image: Debian 11 (Bullseye)
FROM debian:12

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    lsb-release \
    ca-certificates \
    gnupg \
    mariadb-client \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-redis \
    && rm -rf /var/lib/apt/lists/*

# Create runtime directory expected by PHP-FPM
RUN mkdir -p /run/php && chown www-data:www-data /run/php

# Copy configuration files
COPY www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

ENTRYPOINT ["/usr/local/bin/script.sh"]
