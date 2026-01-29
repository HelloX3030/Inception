FROM debian:12

RUN apt-get update && apt-get install -y \
    php8.2-cli \
    php8.2-mysql \
    curl \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Download Adminer
RUN mkdir -p /var/www/adminer \
 && curl -fsSL https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
    -o /var/www/adminer/index.php

WORKDIR /var/www/adminer

EXPOSE 8080

CMD ["php8.2", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]
