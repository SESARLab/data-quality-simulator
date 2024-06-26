.PHONY: build test

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
	docker build --target data-quality-simulator .
	docker run --rm data-quality-simulator --config-file-path=$(CONFIG_FILE_PATH)
endif
	