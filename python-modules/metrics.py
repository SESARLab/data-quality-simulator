from scipy.spatial import distance
import numpy as np

def qualitative(df1, df2):
    ds = []
    ws = []

    for col in df1.columns:
        try:
            p = df1[col].value_counts(normalize=True).sort_index()
            q = df2[col].value_counts(normalize=True).reindex(p.index, fill_value=0.0).sort_index()
            if np.sum(np.asarray(q), axis=0, keepdims=True) != 0:
                ds.append(distance.jensenshannon(p, q))
                ws.append(len(df1[col].unique()) / len(df1[col]))
            else:
                ds.append(1.0)
        except Exception as e:
            print(e)
            ds.append(1.0)
    ws = [w/sum(ws) for w in ws]
    try:
        return np.average(ds,weights=ws)
    except:
        return 1.0
    

def quantitative(df1, df2):
    return len(df2)/len(df1)
