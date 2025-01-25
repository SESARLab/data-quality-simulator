SHELL := /bin/bash

.PHONY: install uninstall run-simulation delete-simulation copy-dataset

# Parameters \
- DRY_RUN: true to enable the dry run
DRY_RUN_OPTIONS := $(if ${DRY_RUN},--dry-run --debug,)
install:
	helm upgrade --install ${DRY_RUN_OPTIONS} setup ./setup

uninstall:
	helm uninstall setup

# Parameters \
- NAME: name of the simulation \
- PARAMETERS: simulation cli parameters
PARAMETERS_OPTION := $(if ${PARAMETERS},--set parameters=${PARAMETERS},)
run-simulation:
	HELM_TEMPLATE="$$(helm template ${NAME} ./run-simulation ${PARAMETERS_OPTION})" && \
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