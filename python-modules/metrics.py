from scipy.spatial import distance
import numpy as np

def qualitative(df1, df2):
    ds = []
    ws = []

    for col in df1.columns:
        p = df1[col].value_counts(normalize=True)
        q = df2[col].value_counts(normalize=True).reindex(p.index, fill_value=0.0)

        if q.empty:
            ds.append(1.0)
        else:
            ds.append(distance.jensenshannon(p, q))
        ws.append(df1[col].nunique() / df1[col].count())
    weight_sum = sum(ws)
    ws = [w/weight_sum for w in ws]

    return np.average(ds,weights=ws)
    

def quantitative(df1, df2):
    return len(df2)/len(df1)
