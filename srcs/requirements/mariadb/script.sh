#!/bin/bash
set -e

DB_NAME="$(cat /run/secrets/db_name)"
DB_USER="$(cat /run/secrets/db_user)"
DB_PASS="$(cat /run/secrets/db_password)"

# Start MariaDB in background (direct daemon, not mysqld_safe)
mariadbd \
  --datadir=/var/lib/mysql \
  --user=mysql \
  --skip-networking=0 \
  --bind-address=0.0.0.0 &
pid="$!"

# Wait for socket
until mysqladmin --protocol=socket ping --silent; do
    sleep 1
done

mysql --protocol=socket -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Bring MariaDB to foreground
wait "$pid"
