#!/bin/bash
set -e

DB_NAME="$(cat /run/secrets/db_name)"
DB_USER="$(cat /run/secrets/db_user)"
DB_PASS="$(cat /run/secrets/db_password)"

# Start MariaDB in background
mysqld_safe --datadir=/var/lib/mysql &
pid="$!"

# Wait for MariaDB to accept connections
until mysqladmin ping --silent; do
    sleep 1
done

# Initialize DB and user (idempotent)
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Bring MariaDB back to foreground
wait "$pid"
