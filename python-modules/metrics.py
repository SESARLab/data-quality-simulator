from scipy.spatial import distance
import numpy as np

# **********************❗❗❗❗❗❗**********************
# Note: lower metric values are considered better
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


def quantitative(df1, df2):
    return df1.dropna().shape[0] / df2.dropna().shape[0]
