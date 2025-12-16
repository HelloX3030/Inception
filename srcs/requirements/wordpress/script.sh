#!/bin/bash
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

# Install WP only if not already present
if [ ! -f wp-load.php ]; then
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	./wp-cli.phar core download --allow-root
	./wp-cli.phar config create --dbname=wordpress --dbuser=wpuser --dbpass=password --dbhost=${DB_HOST} --allow-root
	./wp-cli.phar core install --url=localhost --title=inception --admin_user=admin --admin_password=admin --admin_email=admin@admin.com --allow-root
else
	echo "WordPress already installed, skipping wp-cli install steps"
fi

# Start php-fpm in foreground
php-fpm8.2 -F
