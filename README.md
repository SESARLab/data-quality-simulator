# Data Balance Simulator CLI

To run Swift REPL in a docker container run:

```bash
docker run --rm -it --cap-add=SYS_PTRACE --security-opt seccomp=unconfined swift:5.10.1 swift repl
```

## Run

To run the project in a container, then:

```bash
make run CONFIG_FILE_PATH=config-files/base_config.json SIMULATOR_ARGS=[...]
```

If the environment already have Swift installed (e.g. when you are developing using VSCode devcontainer feature):

```bash
make run IS_DEVCONTAINER=true CONFIG_FILE_PATH=config-files/base_config.json SIMULATOR_ARGS=[...]
```

---

## Simulation Complexity

The number of simulations is determined by the execution parameters:

$\sum_{s = MinServices}^{MaxServices} \sum_{n = MinNodes}^{MaxNodes} \sum_{w = 1}^{min(n, MaxWindowSize)} s^{w} * (n - w + 1) + n$

An execution with:

$
    nodes = 5 \newline
    services = 6 \newline
    maxWindowSize = 4 \newline
$

Includes the following number of samplings:

$
    winSize = 1 \to
    samplings = (6^{1}) * 5 + 5\newline
    winSize = 2 \to
    samplings = (6^{2}) * 4 + 5\newline
    winSize = 3 \to
    samplings = (6^{3}) * 3 + 5\newline
    winSize = 4 \to
    samplings = (6^{4}) * 2 + 5\newline
$

$6^{x}$ represents the number of combinations in a window, which is multiplied by the number of windows in a simulation. After we choose the service, it is executed and the resulting dataset is stored and cached. This is the meaning of $+ n$ (one service for each node).

---

## Datasets

Datasets are located in the `datasets` folder. The following table describes the characteristics of each dataset:

| Dataset | Average of Columns entropy | Variance of Columns entropy | Std Dev of Columns entropy |
|---------|----------------------------|-----------------------------|----------------------------|
| high_variability | 11.80 | 0.24 | 0.49 |
| low_variability | 1.7 | 0.2 | 0.45 |
| inmates_enriched_10k | 5.35 | 13.09 | 3.62 |
| IBM_HR_Analytics_employee_attrition | 3.13 | 8.56 | 2.93 |
| red_wine_quality | 5.61 | 2.01 | 1.42 |
| avocado | 9.36 | 22.13 | 4.7 |

To compute the entropy of each column:

```python
import pandas as pd
import numpy as np
from typing import Dict

dataset = pd.read_csv(dataset_name + ".csv")

dataset_size = len(dataset)

def get_column_frequency(column: pd.Series) -> pd.Series:
    return column.value_counts()

def get_column_probability(column: pd.Series) -> pd.Series:
    return column.value_counts(normalize=True)

def get_column_entropy(column: pd.Series) -> float:
    column_probability = get_column_probability(column)
    return -sum(column_probability * np.log2(column_probability))


entropies = [get_column_entropy(dataset[column]) for column in dataset.columns ]
print(f"{round(np.mean(entropies), 2)}, {round(np.var(entropies), 2)}, {round(np.std(entropies), 2)}")
```

---

## Logging

To set the logger level, create an env variable called `LOGGER_LEVEL` with one of the following values: `trace, debug, info, notice, warning, error, critical` ( default is `info`). The alternative is to pass this variable to `make run`.

---

## DB Migrations and DB queries

For DB migration, run `make migrate-db SQL_CODE="your_migration_sql"`.

To run queries on DB, run `make run-query SQL_CODE="your_plain_sql"`.

---

[Deepnote experiments](https://deepnote.com/workspace/test-efaa-1feb6c70-6750-4e6b-8afd-854661b4e01a/project/Dataset-generation-17111468-e773-4c18-b5d3-b951c564e2bc/notebook/a0b70c155f2e4a4db16548fdf4ff4ddf)