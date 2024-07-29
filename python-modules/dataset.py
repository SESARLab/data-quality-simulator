def inmates_enriched_10k():
    import pandas as pd
    return pd.read_csv("datasets/inmates_enriched_10k.csv")

def high_variability_10k():
    import pandas as pd
    return pd.read_csv("datasets/high_variability_10k.csv")

def low_variability_10k():
    import pandas as pd
    return pd.read_csv("datasets/low_variability_10k.csv")

def avocado():
    import pandas as pd
    return pd.read_csv('datasets/avocado.csv', index_col=[0])