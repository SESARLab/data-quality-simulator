SHELL := /bin/bash

.PHONY: install uninstall run-simulation delete-simulation copy-dataset read-db


# Parameters \
- DRY_RUN: true to enable the dry run
DRY_RUN_OPTIONS := $(if ${DRY_RUN},--dry-run --debug,)
install:
	helm upgrade --install ${DRY_RUN_OPTIONS} setup ./setup


uninstall:
	helm uninstall setup


# Parameters \
- NAME: name of the simulation \
- VALUES_FILE: path of file containing the simulation parameters
run-simulation:
	HELM_TEMPLATE="$$(helm template ${NAME} ./run-simulation --values ${VALUES_FILE})" && \
	echo "$$HELM_TEMPLATE" && \
	printf "\n\nPress [Enter] to apply\n" && \
	read && \
	{ echo "$$HELM_TEMPLATE" | kubectl create -f -; }


# Parameters \
- NAME: name of the simulation 
delete-simulation:
	kubectl delete job -l 'app.kubernetes.io/name=run-simulation,app.kubernetes.io/instance=${NAME}'


# Parameters: \
- FILE_PATH: path of the dataset to move in the volume
copy-dataset:
	POD_NAME="$$(kubectl create -f utils/pod-with-datasets.yaml -o=jsonpath='{ .metadata.name }')" && \
	kubectl wait --timeout=60s --for=jsonpath='{.status.phase}'=Running pod/"$$POD_NAME" && \
	kubectl cp ${FILE_PATH} $$POD_NAME:/datasets && \
	kubectl delete pod "$$POD_NAME"


# Parameters: \
- DB_PATH: path of the sqlite db to read
DB_PATH ?= simulations.db
query-db:
	POD_NAME="$$(kubectl create -f utils/pod-with-db.yaml -o=jsonpath='{ .metadata.name }')" && \
	kubectl wait --timeout=60s --for=jsonpath='{.status.phase}'=Running pod/"$$POD_NAME" && \
	kubectl exec -it $$POD_NAME -- sqlite3 ${DB_PATH} ; \
	kubectl delete pod "$$POD_NAME"