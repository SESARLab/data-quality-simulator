#!/bin/bash

mkdir -p "exec-logs"

LOG_FILE="exec-logs/inmates-simlogs-$1.log"

make run CONFIG_FILE_PATH=config-files/base_config.json \
	SIMULATOR_LOGGER_LEVEL=debug \
	SIMULATOR_ARGS="--seed=$1" 2>&1 | tee "$LOG_FILE" || \
	echo "Simulation with seed $1 failed, see logs: $LOG_FILE" >> exec-logs/errors.log