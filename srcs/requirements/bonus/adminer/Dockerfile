FROM debian:12

RUN apt update && apt install -y \
    php \
    php-mysqli \
    php-pdo \
    php-pdo-mysql \
    curl \
 && rm -rf /var/lib/apt/lists/*

# Download Adminer
RUN mkdir -p /var/www/adminer \
 && curl -L https://www.adminer.org/latest.php -o /var/www/adminer/index.php

WORKDIR /var/www/adminer

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080"]
