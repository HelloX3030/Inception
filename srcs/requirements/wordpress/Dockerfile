FROM debian:latest

RUN apt-get update && apt upgrade && apt install -y \
    php-fpm \
    && rm -rf /var/lib/apt/lists/*

CMD ["php-fpm8.2", "-F"]
