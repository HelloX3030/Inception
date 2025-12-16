# Docker Compose wrapper Makefile

COMPOSE_FOLDER := ./srcs/
COMPOSE := docker compose -f $(COMPOSE_FOLDER)docker-compose.yml
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
	$(COMPOSE) logs

ps:
	docker ps

.PHONY: all make clean fclean re f logs ps
