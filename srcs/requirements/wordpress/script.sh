#!/bin/bash
set -e

cd /var/www/html

DB_HOST="mariadb"
DB_NAME="wordpress"
DB_USER="wpuser"
DB_PASS="password"

echo "tttttttttttttttttttttteeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeesssssssssssssssssssssssssssssssssssssst"
echo "Ensuring WP-CLI is available..."
if [ ! -f wp-cli.phar ]; then
    curl -fLO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
fi

echo "Waiting for MariaDB to be ready..."
for i in {1..30}; do
    if mysqladmin ping -h"$DB_HOST" --silent; then
        echo "MariaDB is ready"
        break
    fi
    echo "MariaDB not ready yet... ($i)"
    sleep 2
done

if ! mysqladmin ping -h"$DB_HOST" --silent; then
    echo "ERROR: MariaDB not reachable after timeout"
    exit 1
fi

# Download WordPress core if missing
if [ ! -f wp-load.php ]; then
    ./wp-cli.phar core download --allow-root
fi

# Create wp-config.php if missing
if [ ! -f wp-config.php ]; then
    ./wp-cli.phar config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASS" \
        --dbhost="$DB_HOST" \
        --allow-root
fi

if ! ./wp-cli.phar core is-installed --allow-root; then
    ./wp-cli.phar core install \
        --url="http://localhost:8080" \
        --title="inception" \
        --admin_user="admin" \
        --admin_password="admin" \
        --admin_email="admin@admin.com" \
        --allow-root
else
    echo "WordPress already installed"
fi

exec php-fpm8.2 -F
