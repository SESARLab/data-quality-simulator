SHELL := /bin/bash
DRY_RUN_OPTIONS := $(if ${DRY_RUN},--dry-run=client,)

run:
	kubectl apply ${DRY_RUN_OPTIONS} -k ./kustomize