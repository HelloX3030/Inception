# Base image: Debian 11 (Bullseye)
FROM debian:11

# Install system dependencies required for:
# - detecting OS version (lsb-release)
# - HTTPS package repositories (ca-certificates, apt-transport-https)
# - fetching external resources (curl)
# Then add the Sury PHP repository to access PHP 7.4 packages,
# install PHP-FPM and common PHP extensions,
# and finally clean apt cache to reduce image size.
RUN apt-get update && apt-get install -y \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    curl \
    && curl -sSL https://packages.sury.org/php/README.txt | bash \
    && apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-cli \
    php7.4-mbstring \
    php7.4-json \
    php7.4-mysql \
    php7.4-opcache \
    && rm -rf /var/lib/apt/lists/*

# Create runtime directory for PHP-FPM sockets and PID files.
# Permissions are set to 777 to avoid permission issues when running
# under different users or orchestration environments.
RUN mkdir -p /run/php && chmod 777 /run/php

# Define the container entrypoint as the PHP-FPM 7.4 binary.
# This ensures the container always starts PHP-FPM.
ENTRYPOINT ["/usr/sbin/php-fpm7.4"]

# Default command passed to the entrypoint:
# -F runs PHP-FPM in the foreground, which is required for Docker
# so the main process stays attached.
CMD ["-F"]
