#!/bin/bash
set -e

cd /var/www/html

DB_HOST="mariadb"

# Docker Secrets
DB_NAME="$(cat /run/secrets/db_name)"
DB_USER="$(cat /run/secrets/db_user)"
DB_PASS="$(cat /run/secrets/db_password)"

WP_ADMIN_USER="$(cat /run/secrets/wp_admin_user)"
WP_ADMIN_PASS="$(cat /run/secrets/wp_admin_password)"
WP_ADMIN_EMAIL="$(cat /run/secrets/wp_admin_email)"

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
        --url="https://localhost" \
        --title="inception" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root
else
    echo "WordPress already installed"
fi

exec php-fpm8.2 -F
