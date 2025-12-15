# Docker Compose wrapper Makefile

COMPOSE := docker compose -f ./srcs/docker-compose.yml
PROJECT := app

all: make

make:
	$(COMPOSE) up

clean:
	$(COMPOSE) down

fclean:
	$(COMPOSE) down --volumes --remove-orphans
	docker system prune -f

re:
	$(COMPOSE) up --build

.PHONY: all make clean fclean re
