SHELL=/bin/bash
uid=$(shell id -u)
gid=$(shell id -g)
SIMULATOR_LOGGER_LEVEL ?= info

.PHONY: build test run get-results count-results delete-all

Package.resolved: Package.swift
ifdef IS_DEVCONTAINER
	swift package resolve
else
	docker build --target export-package-resolved --output . .
endif

build: Package.resolved
ifdef IS_DEVCONTAINER
	swift build --configuration release
else
	docker build --target build .
endif

test:
ifdef IS_DEVCONTAINER
	swift test
else
	docker build --target test .
endif

create-db:
	rm -r db/data
	mkdir -p db/data
ifdef IS_DEVCONTAINER
	echo "Run this task from Host"
	exit 1
else
	uid=$(uid) gid=$(gid) docker compose run --rm db
endif

migrate-db:
ifdef IS_DEVCONTAINER
	echo "Run this task from Host"
	exit 1
else
	uid=$(uid) gid=$(gid) docker compose run --rm db sh -c "echo \"$(SQL_CODE)\" | sqlite3 simulations.db"
endif

run:
	mkdir -p db/data notebooks
ifdef IS_DEVCONTAINER
	swift run DataBalanceSimulator --config-file-path=$(CONFIG_FILE_PATH) \
		--db-path=./db/data/simulations.db
else
	SIMULATOR_CONFIG_FILE_PATH=$(CONFIG_FILE_PATH) \
	SIMULATOR_LOGGER_LEVEL=$(SIMULATOR_LOGGER_LEVEL) uid=$(uid) gid=$(gid) \
		docker compose up --build db simulator
endif

open-notebook:
	uid=$(uid) gid=$(gid) docker compose up -d notebook
	while true; do \
		NOTEBOOK_CONTAINER_STATUS=$$(docker container inspect -f '{{ .State.Health.Status }}' jupyter-notebook); \
		if [ "$$NOTEBOOK_CONTAINER_STATUS" == "healthy" ]; then \
			break; \
		fi; \
		sleep 1; \
	done
	xdg-open http://localhost:8889/lab?token=my-token &> /dev/null
	
get-results:
	uid=$(uid) gid=$(gid) docker compose run --rm get-results

count-results:
	uid=$(uid) gid=$(gid) docker compose run --rm count-results

delete-all:
	uid=$(uid) gid=$(gid) docker compose run --rm delete-all