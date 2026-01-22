COMPOSE_FOLDER := ./srcs
COMPOSE := docker compose -f $(COMPOSE_FOLDER)/docker-compose.yml

# Domain and hosts configuration
LOGIN := lseeger
DOMAIN := $(LOGIN).42.fr
HOSTS_LINE := 127.0.0.1 $(DOMAIN)

# Data directories (subject requirement)
DATA_DIR := /home/$(LOGIN)/data
WP_DATA_DIR := $(DATA_DIR)/wordpress
DB_DATA_DIR := $(DATA_DIR)/mariadb

# Certificates configuration
CERT_DIR := $(COMPOSE_FOLDER)/requirements/nginx/certs
CERT_KEY := $(CERT_DIR)/$(DOMAIN).key
CERT_CRT := $(CERT_DIR)/$(DOMAIN).crt

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
	rm -rf $(CERT_DIR)
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
hosts:
	@echo "Checking /etc/hosts for $(DOMAIN)..."
	@if ! grep -q "$(DOMAIN)" /etc/hosts; then \
		echo "Adding $(DOMAIN) to /etc/hosts"; \
		echo "$(HOSTS_LINE)" | sudo tee -a /etc/hosts > /dev/null; \
	else \
		echo "$(DOMAIN) already exists in /etc/hosts"; \
	fi

### Certificates
certs:
	@mkdir -p $(CERT_DIR)
	@if [ ! -f $(CERT_KEY) ] || [ ! -f $(CERT_CRT) ]; then \
		openssl req -x509 -nodes -days 365 \
		-newkey rsa:2048 \
		-keyout $(CERT_KEY) \
		-out $(CERT_CRT) \
		-subj "/CN=$(DOMAIN)"; \
		echo "Self-signed certs generated"; \
	else \
		echo "Certs already exist"; \
	fi

### Utility targets
logs:
	$(COMPOSE) logs

ps:
	docker ps

.PHONY: all up clean fclean re data hosts certs logs ps
