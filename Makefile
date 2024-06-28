SHELL=/bin/bash
UID=$(shell id -u)
GID=$(shell id -g)

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

run:
ifdef IS_DEVCONTAINER
	/DataBalanceSimulator --config-file-path=$(CONFIG_FILE_PATH)
else
	mkdir -p db/data notebooks
	UID=$(UID) GID=$(GID) docker compose up db simulator
endif
	
get-results:
	UID=$(UID) GID=$(GID) docker compose run --rm get-results

count-results:
	UID=$(UID) GID=$(GID) docker compose run --rm count-results

delete-all:
	UID=$(UID) GID=$(GID) docker compose run --rm delete-all