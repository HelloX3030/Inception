# Base image: Debian 11 (Bullseye)
FROM debian:11

# Install system dependencies and add Sury PHP repository
RUN apt-get update && apt-get install -y \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    curl \
    && curl -sSL https://packages.sury.org/php/README.txt | bash \
    && apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-cli \
    php8.2-mbstring \
    php8.2-mysql \
    php8.2-opcache \
    php8.2-curl \
    php8.2-xml \
    php8.2-zip \
    && rm -rf /var/lib/apt/lists/*

# Create runtime directory for PHP-FPM sockets and PID files
RUN mkdir -p /run/php && chmod 777 /run/php

COPY www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Start PHP-FPM 8.2 as the main container process
ENTRYPOINT ["/usr/sbin/php-fpm8.2"]

# Run PHP-FPM in foreground (required for Docker)
CMD ["-F"]
