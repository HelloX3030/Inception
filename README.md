*This project has been created as part of the 42 curriculum by lseeger.*

# Inception

## Description

This project is part of the **Inception** assignment from the 42 curriculum.  
Its objective is to design and deploy a complete web infrastructure using **Docker** and **Docker Compose**, following modern DevOps principles.

The project demonstrates how multiple services can be isolated, configured, secured, and orchestrated together in a reproducible way. Each service runs in its own container, communicates over a private Docker network, and is explicitly configured without relying on pre-built application images.

The infrastructure includes:
- **Nginx** as an HTTPS reverse proxy and entry point
- **WordPress** running on **PHP-FPM**
- **MariaDB** as the relational database
- **Redis** for WordPress object caching
- **Adminer** for database administration
- **FTP (vsftpd)** for WordPress file management
- A **static website**
- A **monitoring endpoint** using Nginx `stub_status`

All services are built on **Debian 12** and configured using environment variables and Docker secrets.

---

### Use of Docker

Docker is used to:
- Isolate services from one another
- Ensure reproducible builds and executions
- Avoid polluting the host system with dependencies
- Simplify deployment and teardown of the infrastructure

Each service has its own Dockerfile and runs in a dedicated container.  
**Docker Compose** is used to orchestrate the entire stack.

---

### Virtual Machines vs Docker

| Virtual Machines | Docker |
|------------------|--------|
| Full guest OS per instance | Shares host kernel |
| Heavy resource usage | Lightweight |
| Slow startup times | Fast startup |
| Strong isolation | Process-level isolation |

Docker was chosen because it is lighter, faster, and better suited for microservice-style architectures.

---

### Secrets vs Environment Variables

- **Environment variables** are used for non-sensitive configuration:
  - domain names
  - service identifiers
  - version pinning
  - host paths
- **Docker secrets** are used for sensitive data:
  - database credentials
  - WordPress users and passwords
  - Redis password
  - FTP credentials

Secrets are mounted at runtime under `/run/secrets` and are never hard-coded or committed to the repository.

---

### Docker Network vs Host Network

The project uses a **Docker bridge network**.

Advantages:
- Containers communicate via service names (internal DNS)
- Services are isolated from the host network
- Reduced attack surface
- Predictable and portable networking

Using the host network was intentionally avoided to preserve isolation and portability.

---

### Docker Volumes vs Bind Mounts

**Bind mounts** are used for persistent data:
- WordPress files
- MariaDB database files

This allows:
- Data persistence across container rebuilds
- Easy inspection and backup on the host
- Transparent storage during development

Docker-managed volumes could also be used, but bind mounts were chosen for clarity in an educational context.

---

## Instructions

This project provides two complementary documentation files:

- **USER_DOC.md** — User and administrator documentation  
  Explains how to interact with the running infrastructure:
  - what services are provided
  - how to start and stop the stack
  - how to access the websites and administration interfaces
  - where credentials are stored and how to manage them
  - how to verify that each service is running correctly

- **DEV_DOC.md** — Developer documentation  
  Explains how to work with the project from a development and maintenance perspective:
  - how to set up the environment from scratch
  - how configuration, secrets, and data persistence are handled
  - how to build and launch the stack using Makefile and Docker Compose
  - how containers, volumes, and networks are organized

This README focuses on **service verification**, allowing reviewers or users to quickly confirm that the stack is working as intended.

---

### Service Verification

#### WordPress Website

- Public site:  
  `https://your-domain`  
  `https://localhost`

#### WordPress Administration

- Admin dashboard:  
  `https://your-domain/wp-admin`  
  `https://your-domain/wp-login`

Use the WordPress administrator credentials provided via Docker secrets.

---

#### Redis (Object Cache)

Verify that the Redis object cache is active in WordPress:

```bash
docker exec -it -w /var/www/html wp-php \
  ./wp-cli.phar redis status --allow-root
````

Verify Redis activity directly:

```bash
docker exec -it redis sh -c \
  'redis-cli -a "$(cat /run/secrets/redis_password)" info keyspace'
```

A non-empty keyspace confirms Redis is being used.

---

#### FTP (vsftpd)

Install an FTP client (example with FileZilla):

```bash
sudo apt install filezilla
filezilla
```

Connection details:

* Host: `localhost`
* Port: `21`
* Username: value from `secrets/ftp_user`
* Password: value from `secrets/ftp_password`

Successful connection confirms FTP access to WordPress files.

---

#### Static Website

* Static site URL:
  `https://your-static-domain`

The page should load without authentication.

---

#### Adminer (Database Management)

* Adminer interface:
  `https://your-adminer-domain`

Use the MariaDB credentials provided via Docker secrets to log in and access the database.

---

#### Monitoring Endpoint

* Monitoring URL:
  `https://your-monitoring-domain`

This endpoint is protected by HTTP Basic Authentication and exposes Nginx `stub_status` information.

---

## Resources

### Documentation

* Docker: [https://docs.docker.com/](https://docs.docker.com/)
* Docker Compose: [https://docs.docker.com/compose/](https://docs.docker.com/compose/)
* Nginx: [https://nginx.org/en/docs/](https://nginx.org/en/docs/)
* WordPress: [https://wordpress.org/documentation/](https://wordpress.org/documentation/)
* MariaDB: [https://mariadb.com/kb/en/documentation/](https://mariadb.com/kb/en/documentation/)
* Redis: [https://redis.io/docs/](https://redis.io/docs/)
* WP-CLI: [https://developer.wordpress.org/cli/commands/](https://developer.wordpress.org/cli/commands/)
