# Base image: Debian 11 (Bullseye)
FROM debian:11

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    lsb-release \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Add the Sury PHP repository (for PHP 8.2)
RUN curl -fsSL https://packages.sury.org/php/README.txt | bash - && \
    apt-get update && \
    apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY script.sh .
RUN chmod +x ./script.sh
RUN mkdir /run/php/

# Start PHP-FPM 8.2 as the main container process
ENTRYPOINT ["./script.sh"]

