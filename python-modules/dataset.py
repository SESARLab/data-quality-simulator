def inmates_enriched_10k():
    import pandas as pd
    df = pd.read_csv("datasets/inmates_enriched_10k.csv")

    df['date'] = df['date'].astype('datetime64[ns]')
    df['prison_date'] = df['prison_date'].astype('datetime64[ns]')
    df['origin'] = df['origin'].astype('category')
    df['sex'] = df['sex'].astype('category')
    df['age'] = df['age'].astype('UInt8')
    df['born_city'] = df['born_city'].astype('category')
    df['something'] = df['something'].astype('category')

    return df


def high_variability_10k():
    import pandas as pd
    return pd.read_csv("datasets/high_variability_10k.csv")


def low_variability_10k():
    import pandas as pd
    return pd.read_csv("datasets/low_variability_10k.csv")


def avocado():
    import pandas as pd

    df = pd.read_csv('datasets/avocado.csv', index_col=[0])

    df['Date'] = df['Date'].astype('datetime64[ns]')
    df['type'] = df['type'].astype('category')
    df['year'] = df['year'].astype('category')
    df['region'] = df['region'].astype('category')

    return df


def IBM_HR_Analytics_employee_attrition():
    import pandas as pd

    df = pd.read_csv('datasets/IBM_HR_Analytics_employee_attrition.csv')

    df['Age'] = df['Age'].astype('UInt8')
    df['Attrition'] = df['Attrition'].apply(lambda x: x == 'Yes').astype('boolean')
    df['BusinessTravel'] = df['BusinessTravel'].astype('category')
    df['DailyRate'] = df['DailyRate'].astype('UInt16')
    df['Department'] = df['Department'].astype('category')
    df['DistanceFromHome'] = df['DistanceFromHome'].astype('UInt8')
    df['Education'] = df['Education'].astype('category')
    df['EducationField'] = df['EducationField'].astype('category')
    df.drop('EmployeeCount', axis='columns', inplace=True)
    df['EmployeeNumber'] = df['EmployeeNumber'].astype('UInt16')
    df['EnvironmentSatisfaction'] = df['EnvironmentSatisfaction'].astype('category')
    df['Gender'] = df['Gender'].astype('category')
    df['HourlyRate'] = df['HourlyRate'].astype('UInt8')
    df['JobInvolvement'] = df['JobInvolvement'].astype('category')
    df['JobLevel'] = df['JobLevel'].astype('category')
    df['JobRole'] = df['JobRole'].astype('category')
    # many other can be slightly improved
    df['MaritalStatus'] = df['MaritalStatus'].astype('category')
    df['Over18'] = df['Over18'].apply(lambda x: x == 'Y').astype('boolean')
    df['OverTime'] = df['Over18'].apply(lambda x: x == 'Yes').astype('boolean')

    return df


def red_wine_quality():
    import pandas as pd
    import numpy as np

    df = pd.read_csv('datasets/red_wine_quality.csv')

    df['free sulfur dioxide'] = np.floor(df['free sulfur dioxide']).astype('UInt8')
    df['total sulfur dioxide'] = np.floor(df['free sulfur dioxide']).astype('UInt16')
    df['quality'] = df['quality'].astype('category')

    return df