COMPOSE_FOLDER := ./srcs
COMPOSE := docker compose -f $(COMPOSE_FOLDER)/docker-compose.yml

# Domain and hosts configuration
LOGIN := lseeger
DOMAIN := $(LOGIN).42.fr
STATIC_DOMAIN := static.$(DOMAIN)
ADMINER_DOMAIN := adminer.$(DOMAIN)
MONITOR_DOMAIN := monitor.$(DOMAIN)

HOSTS_LINE_MAIN := 127.0.0.1 $(DOMAIN)
HOSTS_LINE_STATIC := 127.0.0.1 $(STATIC_DOMAIN)
HOSTS_LINE_ADMINER := 127.0.0.1 $(ADMINER_DOMAIN)
HOSTS_LINE_MONITOR := 127.0.0.1 $(MONITOR_DOMAIN)

# Data directories (subject requirement)
DATA_DIR := /home/$(LOGIN)/data
WP_DATA_DIR := $(DATA_DIR)/wordpress
DB_DATA_DIR := $(DATA_DIR)/mariadb

# ============================
# Certificates configuration
# ============================

# Nginx TLS certs
NGINX_CERT_DIR := $(COMPOSE_FOLDER)/requirements/nginx/certs
NGINX_CERT_KEY := $(NGINX_CERT_DIR)/$(DOMAIN).key
NGINX_CERT_CRT := $(NGINX_CERT_DIR)/$(DOMAIN).crt

# FTP (FTPS) certs
FTP_CERT_DIR := $(COMPOSE_FOLDER)/requirements/bonus/ftp/certs
FTP_CERT_KEY := $(FTP_CERT_DIR)/ftp.key
FTP_CERT_CRT := $(FTP_CERT_DIR)/ftp.crt

### Default target
all: up

### Start containers
up:
	$(MAKE) data
	$(MAKE) certs
	$(MAKE) hosts
	$(COMPOSE) up -d

### Stop containers
clean:
	$(COMPOSE) down

### Full cleanup (volumes + images + certs)
fclean:
	$(COMPOSE) down --volumes --remove-orphans --rmi all
	rm -rf $(NGINX_CERT_DIR)
	rm -rf $(FTP_CERT_DIR)
	sudo rm -rf $(DATA_DIR)

### Full rebuild (order guaranteed)
re:
	$(MAKE) fclean
	$(MAKE) data
	$(MAKE) certs
	$(MAKE) hosts
	$(COMPOSE) build --no-cache
	$(COMPOSE) up -d

### Data directories (host)
data:
	@echo "Creating data directories in $(DATA_DIR)..."
	sudo mkdir -p $(WP_DATA_DIR)
	sudo mkdir -p $(DB_DATA_DIR)
	sudo chmod 700 $(DATA_DIR)
	sudo chown -R $(LOGIN):$(LOGIN) $(DATA_DIR)

### Hosts file
### Hosts file
hosts:
	@echo "Checking /etc/hosts for domains..."
	@if ! grep -q "$(DOMAIN)" /etc/hosts; then \
		echo "Adding $(DOMAIN) to /etc/hosts"; \
		echo "$(HOSTS_LINE_MAIN)" | sudo tee -a /etc/hosts > /dev/null; \
	else \
		echo "$(DOMAIN) already exists in /etc/hosts"; \
	fi
	@if ! grep -q "$(STATIC_DOMAIN)" /etc/hosts; then \
		echo "Adding $(STATIC_DOMAIN) to /etc/hosts"; \
		echo "$(HOSTS_LINE_STATIC)" | sudo tee -a /etc/hosts > /dev/null; \
	else \
		echo "$(STATIC_DOMAIN) already exists in /etc/hosts"; \
	fi
	@if ! grep -q "$(ADMINER_DOMAIN)" /etc/hosts; then \
	echo "Adding $(ADMINER_DOMAIN) to /etc/hosts"; \
		echo "$(HOSTS_LINE_ADMINER)" | sudo tee -a /etc/hosts > /dev/null; \
	else \
		echo "$(ADMINER_DOMAIN) already exists in /etc/hosts"; \
	fi
	@if ! grep -q "$(MONITOR_DOMAIN)" /etc/hosts; then \
		echo "Adding $(MONITOR_DOMAIN) to /etc/hosts"; \
		echo "$(HOSTS_LINE_MONITOR)" | sudo tee -a /etc/hosts > /dev/null; \
	else \
		echo "$(MONITOR_DOMAIN) already exists in /etc/hosts"; \
	fi

# ============================
# Certificate targets
# ============================

certs: nginx-certs ftp-certs

nginx-certs:
	@mkdir -p $(NGINX_CERT_DIR)
	@if [ ! -f $(NGINX_CERT_KEY) ] || [ ! -f $(NGINX_CERT_CRT) ]; then \
		echo "Generating Nginx TLS certificate..."; \
		openssl req -x509 -nodes -days 365 \
			-newkey rsa:2048 \
			-keyout $(NGINX_CERT_KEY) \
			-out $(NGINX_CERT_CRT) \
			-subj "/CN=$(DOMAIN)"; \
	else \
		echo "Nginx TLS cert already exists"; \
	fi

ftp-certs:
	@mkdir -p $(FTP_CERT_DIR)
	@if [ ! -f $(FTP_CERT_KEY) ] || [ ! -f $(FTP_CERT_CRT) ]; then \
		echo "Generating FTPS certificate..."; \
		openssl req -x509 -nodes -days 365 \
			-newkey rsa:2048 \
			-keyout $(FTP_CERT_KEY) \
			-out $(FTP_CERT_CRT) \
			-subj "/CN=ftp.$(DOMAIN)"; \
	else \
		echo "FTPS cert already exists"; \
	fi

### Utility targets
logs:
	$(COMPOSE) logs

ps:
	docker ps

.PHONY: all up clean fclean re data hosts certs nginx-certs ftp-certs logs ps
