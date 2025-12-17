COMPOSE_FOLDER := ./srcs/
COMPOSE := docker compose -f $(COMPOSE_FOLDER)docker-compose.yml

# Domain and hosts configuration
LOGIN := lseeger
DOMAIN := $(LOGIN).42.fr
HOSTS_LINE := 127.0.0.1 $(DOMAIN)

# Certificates configuration
CERT_DIR := ./srcs/nginx/certs
CERT_KEY := $(CERT_DIR)/$(DOMAIN).key
CERT_CRT := $(CERT_DIR)/$(DOMAIN).crt

all: make

make: certs hosts
	$(COMPOSE) up -d

clean:
	$(COMPOSE) down

fclean:
	$(COMPOSE) down --volumes --remove-orphans
	docker system prune -f
	rm -rf $(CERT_DIR)

re: fclean certs hosts
	$(COMPOSE) up -d --build

# Creation Rules
hosts:
	-@echo "Checking /etc/hosts for $(DOMAIN)..."
	-@if ! grep -q "$(DOMAIN)" /etc/hosts; then \
		echo "Adding $(DOMAIN) to /etc/hosts"; \
		echo "$(HOSTS_LINE)" | sudo tee -a /etc/hosts > /dev/null; \
	else \
		echo "$(DOMAIN) already exists in /etc/hosts"; \
	fi

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

# Util Rules
f:
	$(COMPOSE) up

logs:
	$(COMPOSE) logs

ps:
	docker ps

.PHONY: all make clean fclean re hosts certs f logs ps
