from scipy.spatial import distance
import numpy as np

from pandas import DataFrame
from sqlalchemy import create_engine, types
my_conn = create_engine("mysql+mysqldb://root:r00t@mysql:3306/pippo")  # fill details
my_conn = my_conn.connect()
lowerBound = 0.0
upperBound = 0.0
number_of_nodes = 0
number_of_services = 0


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


def store(item):
    my_conn = create_engine("mysql+mysqldb://root:r00t@mysql:3306/pippo")  # fill details
    my_conn2 = my_conn.connect()
    DataFrame(item, index=[0]).to_sql(f'qualitative_n{number_of_nodes}_s{number_of_services}_{int(lowerBound*100)}_{int(upperBound*100)}', my_conn, if_exists='append', index=False)
    my_conn2.close()
    my_conn.dispose()