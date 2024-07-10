import pandas as pd
import numpy as np

# sample eliminates the rows, instead I want to None them
# return df.sample(
#     frac=frac,
#     random_state=random_state
# )
def sample_rows(df: pd.DataFrame, 
                frac: float, 
                random_state: int, 
                in_place: bool) -> pd.DataFrame:
    new_df = df if in_place else df.copy()
    rng = np.random.default_rng(random_state)
    none_rows_size = int(len(new_df) * (1 - frac))
    random_indices = rng.choice(new_df.index, none_rows_size, replace=False)
    new_df.loc[random_indices, :] = None

    return new_df


def sample_columns(df: pd.DataFrame, 
                   columns_frac: float, 
                   rows_frac: float, 
                   random_state: int,
                   in_place: bool) -> pd.DataFrame:
    new_df = df if in_place else df.copy()
    rng = np.random.default_rng(random_state)
    columns_to_filter_count = max(1, int(len(new_df.columns) * (1 - columns_frac)))
    columns_to_filter = rng.choice(new_df.columns, columns_to_filter_count, replace=False)

    none_rows_size = int(len(new_df) * (1 - rows_frac))
    for column_name in columns_to_filter:
        random_indices = rng.choice(new_df.index, none_rows_size, replace=False)
        new_df.loc[random_indices, column_name] = None

    return new_df