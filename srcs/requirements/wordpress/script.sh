#!/bin/bash
set -e

ensure_define() {
    local key="$1"
    local value="$2"

    if grep -Eq "^[[:space:]]*define\([[:space:]]*'$key'" wp-config.php; then
        sed -i "/^[[:space:]]*define[[:space:]]*('$key'/c\define('$key', $value);" wp-config.php
    else
        sed -i "/require_once .*wp-settings.php/i define('$key', $value);" wp-config.php
    fi
}

cd /var/www/html

# =========================
# Configuration (env-based)
# =========================
DOMAIN="${DOMAIN:?DOMAIN is required}"
DB_HOST="${DB_HOST:?DB_HOST is required}"
WP_TITLE="${WP_TITLE:?WP_TITLE is required}"
WP_URL="https://${DOMAIN}"

WP_CLI_VERSION="${WP_CLI_VERSION:?WP_CLI_VERSION is required}"
WP_VERSION="${WP_VERSION:?WP_VERSION is required}"
REDIS_CACHE_VERSION="${REDIS_CACHE_VERSION:?REDIS_CACHE_VERSION is required}"

# =========================
# Secrets
# =========================
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

# =========================
# WP-CLI
# =========================
echo "Ensuring WP-CLI is available..."
if [ ! -f wp-cli.phar ]; then
    curl -fsSL \
      https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar \
      -o wp-cli.phar
    chmod +x wp-cli.phar
fi

# =========================
# MariaDB wait
# =========================
echo "Waiting for MariaDB to be ready..."
for i in {1..30}; do
    if mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" --silent; then
        echo "MariaDB is ready"
        break
    fi
    echo "MariaDB not ready yet... ($i)"
    sleep 2
done

if ! mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" --silent; then
    echo "ERROR: MariaDB not reachable after timeout"
    exit 1
fi

# =========================
# WordPress core
# =========================
if [ ! -f wp-load.php ]; then
    ./wp-cli.phar core download \
        --version="$WP_VERSION" \
        --allow-root
fi

if [ ! -f wp-config.php ]; then
    ./wp-cli.phar config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASS" \
        --dbhost="$DB_HOST" \
        --allow-root
fi

# =========================
# Redis config
# =========================
ensure_define "WP_REDIS_HOST" "'redis'"
ensure_define "WP_REDIS_PORT" "6379"
ensure_define "WP_CACHE" "true"
ensure_define "WP_REDIS_PASSWORD" "'$REDIS_PASS'"

# =========================
# Install WordPress
# =========================
if ! ./wp-cli.phar core is-installed --allow-root; then
    ./wp-cli.phar core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root
else
    echo "WordPress already installed"
fi

# =========================
# Users
# =========================
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

# =========================
# Redis plugin
# =========================
if ! ./wp-cli.phar plugin is-installed redis-cache --allow-root; then
    ./wp-cli.phar plugin install redis-cache \
        --version="$REDIS_CACHE_VERSION" \
        --activate \
        --allow-root
fi

if ./wp-cli.phar core is-installed --allow-root && [ ! -f wp-content/object-cache.php ]; then
    ./wp-cli.phar redis enable --allow-root
fi

exec php-fpm8.2 -F
