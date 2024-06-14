.PHONY: build

Package.resolved: Package.swift
	docker build --target export-package-resolved --output . .

build: Package.resolved
	