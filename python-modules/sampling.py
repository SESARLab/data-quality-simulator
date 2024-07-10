import pandas as pd
import numpy as np

def sample_rows(df: pd.DataFrame, frac: float, random_state: int) -> pd.DataFrame:
    # sample eliminates the rows, instead I want to None them
    # return df.sample(
    #     frac=frac,
    #     random_state=random_state
    # )

    rng = np.random.default_rng(random_state)
    none_rows_size = int(len(df) * (1 - frac))
    random_indices = rng.choice(df.index, none_rows_size, replace=False)
    df.loc[random_indices, :] = None

    return df

def sample_columns(df: pd.DataFrame, 
                   columns_frac: float, 
                   rows_frac: float, 
                   random_state: int) -> pd.DataFrame:
    rng = np.random.default_rng(random_state)
    columns_to_filter_count = max(1, int(len(df.columns) * (1 - columns_frac)))
    columns_to_filter = rng.choice(df.columns, columns_to_filter_count, replace=False)

    none_rows_size = int(len(df) * (1 - rows_frac))
    for column_name in columns_to_filter:
        random_indices = rng.choice(df.index, none_rows_size, replace=False)
        df.loc[random_indices, column_name] = None

    return df