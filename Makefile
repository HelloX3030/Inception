# Docker Compose wrapper Makefile

COMPOSE_PATH := ./srcs/docker-compose.yml
COMPOSE := docker compose -f $(COMPOSE_PATH)
PROJECT := app

all: make

make:
	$(COMPOSE) up -d

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
	$(COMPOSE_PATH) logs

ps:
	docker ps

.PHONY: all make clean fclean re f logs ps
