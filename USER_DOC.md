# User Documentation

This document explains how an **end user or administrator** can interact with the Inception project once it is set up.  
It describes the available services, how to start and stop the stack, how to access interfaces, where credentials are located, and how to verify that everything is running correctly.

---

## 1. Provided Services

The stack provides the following services:

- **WordPress**  
  A content management system accessible via HTTPS.

- **WordPress Administration Panel**  
  Used to manage content, users, and settings.

- **MariaDB**  
  Database backend used internally by WordPress.

- **Redis**  
  Used as an object cache to improve WordPress performance.

- **Adminer**  
  Web-based database management interface.

- **FTP (vsftpd)**  
  Allows file access to WordPress content.

- **Static Website**  
  A simple static page served by Nginx.

- **Monitoring Endpoint**  
  Displays basic Nginx status information and is protected by authentication.

All services are accessible through HTTPS and routed by Nginx.

---

## 2. Starting and Stopping the Project

### Start the Stack

From the project root directory:

```bash
make up
````

This starts all required services automatically.

---

### Stop the Stack

```bash
make down
```

This stops all running containers while keeping stored data intact.

---

## 3. Accessing the Services

### WordPress Website

* Main website:
  `https://your-domain`
  `https://localhost`

---

### WordPress Administration

* Admin panel:
  `https://your-domain/wp-admin`
  `https://your-domain/wp-login`

Log in using the WordPress administrator credentials.

---

### Adminer (Database Management)

* URL:
  `https://your-adminer-domain`

Use the MariaDB credentials to log in and manage the database.

---

### Static Website

* URL:
  `https://your-static-domain`

This page does not require authentication.

---

### Monitoring Endpoint

* URL:
  `https://your-monitoring-domain`

Access is protected by HTTP Basic Authentication.

---

## 4. Credentials Management

All sensitive credentials are stored as **Docker secrets**.

They are located in the `secrets/` directory at the root of the project.

Examples:

* Database name, user, and password
* WordPress administrator and user credentials
* Redis password
* FTP username and password
* Monitoring authentication file

⚠️ Credentials are **not** stored in configuration files or environment variables and should never be shared or committed to version control.

---

## 5. Verifying That Services Are Running

### Check Running Containers

```bash
docker ps
```

All services should appear as running containers.

---

### Verify WordPress

Open the WordPress website in a browser and ensure the page loads correctly.

---

### Verify Redis

Check Redis object cache status in WordPress:

```bash
docker exec -it -w /var/www/html wp-php \
  ./wp-cli.phar redis status --allow-root
```

Check Redis activity directly:

```bash
docker exec -it redis sh -c \
  'redis-cli -a "$(cat /run/secrets/redis_password)" info keyspace'
```

A non-empty keyspace indicates Redis is in use.

---

### Verify FTP

Install an FTP client (example):

```bash
sudo apt install filezilla
filezilla
```

Connection details:

* Host: `localhost`
* Port: `21`
* Username and password: from FTP secrets

A successful connection confirms FTP access.

---

### Verify Adminer

Open the Adminer URL and log in using MariaDB credentials.
Successful login confirms database accessibility.

---

## 6. Notes

* All services are exposed over HTTPS only
* Credentials are managed via Docker secrets
* Data persists across restarts
* No manual container interaction is required for normal usage

This documentation is intended to help users and administrators verify and interact with the running infrastructure without needing development knowledge.
