#!/bin/bash
set -e

ensure_define() {
    local key="$1"
    local value="$2"

    if grep -q "^define('$key'" wp-config.php; then
        sed -i "s|^define('$key'.*|define('$key', $value);|" wp-config.php
    else
        sed -i "/require_once .*wp-settings.php/i define('$key', $value);" wp-config.php
    fi
}

cd /var/www/html

DB_HOST="mariadb"

# Docker Secrets
DB_NAME="$(cat /run/secrets/db_name)"
DB_USER="$(cat /run/secrets/db_user)"
DB_PASS="$(cat /run/secrets/db_password)"

WP_ADMIN_USER="$(cat /run/secrets/wp_admin_user)"
WP_ADMIN_PASS="$(cat /run/secrets/wp_admin_password)"
WP_ADMIN_EMAIL="$(cat /run/secrets/wp_admin_email)"

WP_USER_NAME="$(cat /run/secrets/wp_user_name)"
WP_USER_PASS="$(cat /run/secrets/wp_user_password)"
WP_USER_EMAIL="$(cat /run/secrets/wp_user_email)"

REDIS_PASS="$(cat /run/secrets/redis_password)"

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

# Ensure Redis configuration
ensure_define "WP_REDIS_HOST" "'redis'"
ensure_define "WP_REDIS_PORT" "6379"
ensure_define "WP_CACHE" "true"
ensure_define "WP_REDIS_PASSWORD" "'$REDIS_PASS'"

# Install WordPress if not installed
if ! ./wp-cli.phar core is-installed --allow-root; then
    ./wp-cli.phar core install \
        --url="https://lseeger.42.fr" \
        --title="inception" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root
else
    echo "WordPress already installed"
fi

# Create normal user
if ! ./wp-cli.phar user get "$WP_USER_NAME" --allow-root >/dev/null 2>&1; then
    ./wp-cli.phar user create \
        "$WP_USER_NAME" \
        "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASS" \
        --role=author \
        --allow-root
else
    echo "WordPress user '$WP_USER_NAME' already exists"
fi

# Install and enable Redis Object Cache plugin
if ! ./wp-cli.phar plugin is-installed redis-cache --allow-root; then
    ./wp-cli.phar plugin install redis-cache --activate --allow-root
fi

# Enable Redis object cache (only after WP is fully installed)
if ./wp-cli.phar core is-installed --allow-root; then
    if [ ! -f wp-content/object-cache.php ]; then
        echo "Enabling Redis object cache..."
        for i in {1..10}; do
            if ./wp-cli.phar redis enable --allow-root; then
                echo "Redis object cache enabled"
                break
            fi
            echo "Redis not ready yet, retrying ($i/10)..."
            sleep 2
        done
    else
        echo "Redis already enabled, skipping"
    fi
else
    echo "WordPress not installed yet, skipping Redis enable"
fi

exec php-fpm8.2 -F
