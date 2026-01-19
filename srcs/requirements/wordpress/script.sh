#!/bin/bash
set -e

cd /var/www/html

DB_HOST="mariadb"
DB_PORT=3306

# Wait for MariaDB to be reachable
echo "Waiting for database at ${DB_HOST}:${DB_PORT}..."
for i in {1..30}; do
    if nc -z ${DB_HOST} ${DB_PORT}; then
        echo "Database is up"
        break
    fi
    echo "Still waiting... ($i)"
    sleep 1
done

# Download wp-cli if missing
if [ ! -f wp-cli.phar ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
fi

# Download WordPress core if missing
if [ ! -f wp-load.php ]; then
    ./wp-cli.phar core download --allow-root
fi

# Create wp-config.php if missing
if [ ! -f wp-config.php ]; then
    ./wp-cli.phar config create \
        --dbname=wordpress \
        --dbuser=wpuser \
        --dbpass=password \
        --dbhost=${DB_HOST} \
        --allow-root
else
	echo "wp-config.php already exists"
fi

# Install WordPress only if NOT installed
if ! ./wp-cli.phar core is-installed --allow-root; then
    ./wp-cli.phar core install \
        --url=localhost \
        --title=inception \
        --admin_user=admin \
        --admin_password=admin \
        --admin_email=admin@admin.com \
        --allow-root
else
    echo "WordPress already installed"
fi

exec php-fpm8.2 -F
