.PHONY: help fetch build up down logs ps clean drill
.DEFAULT_GOAL := help

help:
	@grep -E '^[a-z]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "%-8s %s\n", $$1, $$2}'

fetch:
	./scripts/fetch-upstream.sh

build: fetch
	docker compose build

up: fetch
	docker compose up --build -d
	@echo "game: http://localhost:8080 api: :3001 ws: :3002 auth: :3004"

down:
	docker compose down

logs:
	docker compose logs -f --tail=100

ps:
	docker compose ps

clean:
	docker compose down -v --rmi local
	rm -rf upstream

drill:
	$(MAKE) clean
	$(MAKE) up
	docker compose ps