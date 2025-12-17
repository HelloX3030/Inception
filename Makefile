COMPOSE_FOLDER := ./srcs/
COMPOSE := docker compose -f $(COMPOSE_FOLDER)docker-compose.yml

LOGIN := lseeger
DOMAIN := $(LOGIN).42.fr
HOSTS_LINE := 127.0.0.1 $(DOMAIN)

all: make

make: hosts
	$(COMPOSE) up -d

hosts:
	-@echo "Checking /etc/hosts for $(DOMAIN)..."
	-@if ! grep -q "$(DOMAIN)" /etc/hosts; then \
		echo "Adding $(DOMAIN) to /etc/hosts"; \
		echo "$(HOSTS_LINE)" | sudo tee -a /etc/hosts > /dev/null; \
	else \
		echo "$(DOMAIN) already exists in /etc/hosts"; \
	fi

clean:
	$(COMPOSE) down

fclean:
	$(COMPOSE) down --volumes --remove-orphans
	docker system prune -f

re:
	$(COMPOSE) up -d --build

f:
	$(COMPOSE) up

logs:
	$(COMPOSE) logs

ps:
	docker ps

.PHONY: all make hosts clean fclean re f logs ps
