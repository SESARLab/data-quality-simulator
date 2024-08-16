#!/bin/bash

for seed in {1..20}
do
    echo "Starting simulation with seed $seed"
    nohup ./run-simulation.sh "$seed" &> /dev/null &
    sleep 10
done