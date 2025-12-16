# Base image: Debian 11 (Bullseye)
FROM debian:11

# Install system dependencies and add Sury PHP repository
RUN apt-get update && apt-get install -y \
    curl \
    php8.2-fpm \
    php8.2-mysql \
    && rm -rf /var/lib/apt/lists/*

COPY www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY script.sh . && chmod +x ./script.sh

# Start PHP-FPM 8.2 as the main container process
ENTRYPOINT ["./script.sh"]
