# Developer Documentation

This document describes how a **developer** can set up, build, run, and maintain the Inception project.  
It focuses on environment preparation, configuration, container management, and data persistence.

---

## 1. Prerequisites

### Required Packages

Install the following packages on the host system:

```bash
sudo apt install docker.io docker-compose make apache2-utils
````

### User Permissions

The current user must belong to the `docker` group in order to run Docker commands without `sudo`.

```bash
sudo usermod -aG docker your-user
sudo usermod -aG sudo your-user
```

⚠️ After modifying group memberships, **log out and log back in** for the changes to apply.

---

## 2. Environment Configuration

### `.env` File

All non-sensitive configuration is defined in a `.env` file located at the **root of the project**.
Docker Compose automatically loads this file.

Create the file with the required variables:

```bash
cat <<EOF > .env
# Domains
LOGIN=your-user
DOMAIN=your-user.42.fr
ADMINER_DOMAIN=adminer.your-user.42.fr
MONITOR_DOMAIN=monitor.your-user.42.fr
STATIC_DOMAIN=static.your-user.42.fr

# Application names
DB_HOST=mariadb
WP_TITLE=inception

# Persistent data directories (host paths)
WP_DATA_DIR=/home/your-user/data/wordpress
DB_DATA_DIR=/home/your-user/data/mariadb

# Version pinning
WP_CLI_VERSION=2.10.0
WP_VERSION=6.5.3
REDIS_CACHE_VERSION=2.5.3
EOF
```

All variables are **mandatory**.
Containers will fail fast if required variables are missing.

---

## 3. Secrets Management

Sensitive data is handled using **Docker secrets**.
Secrets are stored as files and mounted into containers at runtime under `/run/secrets`.

### Secrets Directory

```bash
mkdir -p secrets
chmod 700 secrets
```

### Required Secret Files

> The values below are **examples only**.
> Never use weak or real credentials in a public repository.

```bash
# MariaDB / WordPress database
echo "db-test" > secrets/db_name
echo "db-test-user" > secrets/db_user
echo "change-me" > secrets/db_password

# WordPress administrator
echo "wp" > secrets/wp_admin_user
echo "change-me" > secrets/wp_admin_password
echo "wp@wp.com" > secrets/wp_admin_email

# WordPress normal user
echo "wp-user" > secrets/wp_user_name
echo "change-me" > secrets/wp_user_password
echo "user@user.com" > secrets/wp_user_email

# Redis
echo "change-me" > secrets/redis_password

# FTP
echo "ftpuser" > secrets/ftp_user
echo "change-me" > secrets/ftp_password
```

---

## 4. Monitoring Authentication

The monitoring endpoint uses HTTP Basic Authentication.

Create the credentials file:

```bash
mkdir -p secrets/auth
htpasswd -c secrets/auth/monitor.htpasswd your-monitor-user
```

This file is mounted into the Nginx container and used by the monitoring virtual host.

---

## 5. Building and Launching the Project

### Build and Start

From the project root, use the Makefile:

```bash
make
```

This command:

* builds all Docker images
* creates the Docker network
* starts all containers in the correct order

### Stop and Clean Up

```bash
make clean
```

This stops all containers while preserving persistent data.

---

## 6. Managing Containers and Volumes

### View Running Containers

```bash
docker ps
```

### View Logs

```bash
make logs
```

### Enter a Container

```bash
docker exec -it wp-php sh
```

---

## 7. Data Persistence

### Persistent Data Locations

The project uses **bind mounts** for persistent storage.

| Service   | Host Path      | Purpose                     |
| --------- | -------------- | --------------------------- |
| WordPress | `$WP_DATA_DIR` | WordPress files and uploads |
| MariaDB   | `$DB_DATA_DIR` | Database data files         |

Because bind mounts are used:

* data survives container rebuilds
* data can be inspected directly on the host
* backups can be performed easily

### Reset All

```bash
make fclean
```

⚠️ This permanently deletes all WordPress and database data.

---

## 8. Notes for Developers

* All services run on **Debian 12**
* No `latest` tags are used
* Versions are explicitly pinned via environment variables
* Nginx configuration files are generated at runtime from templates
* Secrets are never committed to Git
* Configuration errors are designed to fail fast

This structure ensures reproducibility, security, and clarity for both development and evaluation.
