.PHONY: build test

Package.resolved: Package.swift
	# docker build --target export-package-resolved --output . .
	swift package resolve

build: Package.resolved
	swift build

test:
	swift test

run:
	swift run DataBalanceSimulator --config-file-path=$(CONFIG_FILE_PATH)
	