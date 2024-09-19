from scipy.spatial import distance
import numpy as np

# **********************❗❗❗❗❗❗**********************
# Note: lower metric values are considered better

# df1 is the original dataset
# df2 is the transformed dataset
# *********************************************************

# qualitative without none
# def qualitative(df1, df2):
#     ds = []
#     ws = []

#     for col in df1.columns:
#         p = df1[col].value_counts(normalize=True)
#         q = df2[col].value_counts(normalize=True).reindex(p.index, fill_value=0.0)

#         if q.empty:
#             ds.append(1.0)
#         else:
#             ds.append(distance.jensenshannon(p, q))
#         ws.append(df1[col].nunique() / df1[col].count())
#     weight_sum = sum(ws)
#     ws = [w/weight_sum for w in ws]

#     return np.average(ds,weights=ws)

# qualitative with none
def qualitative(df1, df2):
    ds = []
    ws = []

    for col in df1.columns:
        df1_value_counts = df1[col].value_counts(normalize=True, dropna=False)
        df2_value_counts = df2[col].value_counts(normalize=True, dropna=False)
        # TODO: instead of combining the indexes, I could just add the None/np.NaN/pd.NA entry
        # see https://pandas.pydata.org/docs/user_guide/missing_data.html
        combined_index = df1_value_counts.index.union(df2_value_counts.index, sort=True)
        p = df1_value_counts.reindex(combined_index, fill_value=0.0) 
        q = df2_value_counts.reindex(combined_index, fill_value=0.0)

        ds.append(distance.jensenshannon(p, q))
        ws.append(df1[col].nunique() / df1[col].count())
    weight_sum = sum(ws)
    ws = [w/weight_sum for w in ws]

    return np.average(ds,weights=ws)


def non_none_percentage(df1, df2) -> float:
    df1_non_none_cells = df1.count().sum()
    df2_non_none_cells = df2.count().sum()

    return df2_non_none_cells / df1_non_none_cells


def quantitative(df1, df2):
    return 1 - non_none_percentage(df1, df2)


def _get_column_entropy(column) -> float:
    column_probability = column.value_counts(normalize=True, dropna=False)
    column_probability = column_probability[column_probability > 0]
    return -sum(column_probability * np.log2(column_probability))


def _get_dataset_entropy(dataset) -> float:
    entropies = [_get_column_entropy(dataset[column]) for column in dataset.columns]
    return np.mean(entropies)


def entropy_diff(df1, df2):
    original_entropy = _get_dataset_entropy(df1)
    new_entropy = _get_dataset_entropy(df2)

    return abs(original_entropy - new_entropy)


def entropy_ratio(df1, df2):
    original_entropy = _get_dataset_entropy(df1)
    new_entropy = _get_dataset_entropy(df2)

    if new_entropy > original_entropy:
        print('!!!!!!!!!!!! new entropy > original entropy !!!!!!!!!!!!')

    return 1 - new_entropy / original_entropy 