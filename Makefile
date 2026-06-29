# Convenience wrappers. Run `make help` to list targets.
.DEFAULT_GOAL := help

.PHONY: help up down logs ps test fmt seed

help: ## List available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-8s\033[0m %s\n", $$1, $$2}'

up: ## Build and start the full stack (db, redis, api, web)
	docker compose up --build

down: ## Stop and remove containers
	docker compose down

logs: ## Tail logs from all services
	docker compose logs -f

ps: ## Show running services
	docker compose ps

test: ## Run backend tests inside the api container
	docker compose run --rm api pytest

fmt: ## Lint + autofix backend with ruff
	docker compose run --rm api ruff check --fix .

seed: ## POST a few sample records via the API
	./scripts/seed.sh
