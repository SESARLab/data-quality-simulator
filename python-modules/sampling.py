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


# old version of column sampling
#
# def sample_columns(df: pd.DataFrame, 
#                    columns_frac: float, 
#                    rows_frac: float, 
#                    random_state: int,
#                    in_place: bool) -> pd.DataFrame:
#     new_df = df if in_place else df.copy()
#     rng = np.random.default_rng(random_state)
#     columns_to_filter_count = max(1, int(len(new_df.columns) * (1 - columns_frac)))
#     columns_to_filter = rng.choice(new_df.columns, columns_to_filter_count, replace=False)

#     none_rows_size = int(len(new_df) * (1 - rows_frac))
#     for column_name in columns_to_filter:
#         random_indices = rng.choice(new_df.index, none_rows_size, replace=False)
#         new_df.loc[random_indices, column_name] = None

#     return new_df


def sample_columns(df: pd.DataFrame, 
                   df_with_categories: pd.DataFrame,
                   columns_frac: float,
                   cat_frac: float,
                   random_state: int,
                   in_place: bool = False) -> pd.Series:
    new_df = df if in_place else df.copy()
    rng = np.random.default_rng(random_state)
    columns_to_filter_count = max(1, int(len(new_df.columns) * (1 - columns_frac)))
    columns_to_filter = rng.choice(new_df.columns, columns_to_filter_count, replace=False)

    for column in columns_to_filter:
        column_categories = df_with_categories[column].dtype.categories
        categories_to_filter_count = max(1, int(len(column_categories) * (1 - cat_frac)))
        categories_to_filter = rng.choice(column_categories, categories_to_filter_count, replace=False)
        print(categories_to_filter)

        for category in categories_to_filter:
            indexes_to_none = df_with_categories[column].loc[lambda x: x == category].index
            new_df.loc[indexes_to_none, column] = None

    return new_df


def create_categories(column: pd.Series, rng: np.random.Generator) -> pd.Series:
    '''
    Creates bins having the same range of values and assign each value to the closest bin.
    returns a Series of Categoricals, where each category is a bin
    '''
    if pd.api.types.is_integer_dtype(column):
        max_categories_count = len(column.unique())
        categories_count = 1 if max_categories_count == 1 else rng.integers(2, max_categories_count, size=1, endpoint=True)[0]
        return pd.cut(column, bins=categories_count, precision=0, include_lowest=True)

    if pd.api.types.is_float_dtype(column):
        max_categories_count = len(column.unique())
        categories_count = 1 if max_categories_count == 1 else \
            rng.integers(2, min(max_categories_count, np.sqrt(len(column))), size=1, endpoint=True)[0]
        values_range = column.max() - column.min()
        precision = len(str(categories_count)) + (0 if values_range > 0 else \
            len(str(int(1 // values_range))))
        return pd.cut(column, bins=categories_count, precision=precision, include_lowest=True)

    if pd.api.types.is_bool_dtype(column):
        return pd.Categorical(column, categories=[False, True])

    #if pd.api.types.is_string_dtype(column):
    column_hashes = column.map(lambda x: hash(x)) # TODO change hash function
    max_categories_count = len(column_hashes.unique())
    categories_count = 1 if max_categories_count == 1 else rng.integers(2, max_categories_count, size=1, endpoint=True)[0]
    return pd.cut(column_hashes, bins=categories_count, precision=0, include_lowest=True)
    

def create_categorical_df(df: pd.DataFrame, random_state: int) -> pd.DataFrame:
    rng = np.random.default_rng(random_state)
    new_df = pd.DataFrame()
    for column in df.columns:
        new_df[column] = create_categories(df[column], rng)
    return new_df