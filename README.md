# Setup

## Packages
You need to install this packages, to properly use the setup

```bash
apt install docker.io docker-compose make apache2-utils
```

Keep in mind, that you need to give your user the needed permissions.
```bash
usermod -aG sudo lseeger
usermod -aG docker lseeger
```
And after this, you need to logout, so that the permissions actualy apply.

## Envs
Create a file with the nessecary envs, at the root of the project.

```bash
echo "
# Domains
LOGIN=lseeger
DOMAIN=lseeger.42.fr
ADMINER_DOMAIN=adminer.lseeger.42.fr
MONITOR_DOMAIN=monitor.lseeger.42.fr
STATIC_DOMAIN=static.lseeger.42.fr

# Names
DB_HOST=mariadb
WP_TITLE=inception

# Folders
WP_DATA_DIR=/home/lseeger/data/wordpress
DB_DATA_DIR=/home/lseeger/data/mariadb

# Versions
WP_CLI_VERSION=2.10.0
WP_VERSION=6.5.3
REDIS_CACHE_VERSION=2.5.3
" > .env
```

## Passwords
You need to create this files, with the passwords. Here just an example, what needs to be created. **Don't use this passwords, they are not save!**

```bash
# Create secrets directory
mkdir -p secrets
chmod 700 secrets

# MariaDB / WordPress database secrets
echo "db-test" > secrets/db_name
echo "db-test-user" > secrets/db_user
echo "change-me" > secrets/db_password

# WordPress admin user (administrator role)
echo "wp" > secrets/wp_admin_user
echo "change-me" > secrets/wp_admin_password
echo "wp@wp.com" > secrets/wp_admin_email

# WordPress normal user (subscriber role)
echo "wp-user" > secrets/wp_user_name
echo "change-me" > secrets/wp_user_password
echo "user@user.com" > secrets/wp_user_email

# Redis Password
echo "change-me" > secrets/redis_password

# FTP 
echo "ftpuser" > secrets/ftp_user
echo "change-me" > secrets/ftp_password

```

## Monitor Setup
```bash
mkdir -p secrets/auth
htpasswd -c secrets/auth/monitor.htpasswd your-monitor-user
```

---

# Wordpress Page
lseeger.42.fr
localhost

# Wordpress Management Page
lseeger.42.fr/wp-admin
lseeger.42.fr/wp-login

# Verify Redis Works
```bash
docker exec -it -w /var/www/html wp-php ./wp-cli.phar redis status --allow-root
docker exec -it redis sh -c 'redis-cli -a "$(cat /run/secrets/redis_password)" info keyspace'
```

# Verify ftp workes
```bash
apt install filezilla
filezilla
```
=> than connect to localhost using user + password you specified (Port 21)

# Verify Static Website
static.lseeger.42.fr

# Verify Adminer
adminer.lseeger.42.fr
=> Use Maria db-Credentials
