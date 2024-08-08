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
    import numpy as np

    DATASET_SIZE = 10_000
    RANDOM_SEED = 1

    rng = np.random.default_rng(RANDOM_SEED)
    categories_for_column = [
        [''.join([f'{chr(ord("a") + rng.integers(0, 26))}' for c in range(3)]) for _ in range(DATASET_SIZE)],
        list(range(DATASET_SIZE // 4)),
        [''.join([f'{chr(ord("a") + rng.integers(0, 26))}' for c in range(4)]) for _ in range(DATASET_SIZE)],
        list(range(DATASET_SIZE // 3)),
        list(range(DATASET_SIZE // 2))
    ]

    columns_data = [rng.choice(x, size=DATASET_SIZE, replace=True) for x in categories_for_column]
    schema = {
        'col_0': 'string',
        'col_1': 'int16',
        'col_2': 'string',
        'col_3': 'int16',
        'col_4': 'int16'
    }
    return pd.DataFrame({ f'col_{i}':col_data for i, col_data in enumerate(columns_data)}).astype(schema)


def low_variability_10k():
    import pandas as pd
    import numpy as np

    DATASET_SIZE = 10_000
    RANDOM_SEED = 1

    rng = np.random.default_rng(RANDOM_SEED)
    categories_for_column = [
        ['it', 'sp', 'gr'],
        list(range(3)),
        [True, False],
        ['r', 'g', 'b', 'y'],
        list(range(1, 6))
    ]

    columns_data = [rng.choice(x, size=DATASET_SIZE, replace=True) for x in categories_for_column]
    schema = {
            'col_0': 'category',
            'col_1': 'category',
            'col_2': 'boolean',
            'col_3': 'category',
            'col_4': 'category'
        }
    return pd.DataFrame({ f'col_{i}':col_data for i, col_data in enumerate(columns_data)}).astype(schema)


def avocado():
    import pandas as pd

    df = pd.read_csv('datasets/avocado.csv', usecols=lambda x: x != 'Unnamed: 0')

    df['Date'] = df['Date'].astype('datetime64[ns]')
    df['type'] = df['type'].astype('category')
    df['year'] = df['year'].astype('category')
    df['region'] = df['region'].astype('category')

    return df


def IBM_HR_Analytics_employee_attrition():
    import pandas as pd

    df = pd.read_csv('datasets/IBM_HR_Analytics_employee_attrition.csv')

    # these columns could be dropped because they have a unique value
    # df.drop('StandardHours', axis='columns', inplace=True)
    # df.drop('EmployeeCount', axis='columns', inplace=True)
    df['Age'] = df['Age'].astype('UInt8')
    df['Attrition'] = df['Attrition'].apply(lambda x: x == 'Yes').astype('boolean')
    df['BusinessTravel'] = df['BusinessTravel'].astype('category')
    df['DailyRate'] = df['DailyRate'].astype('UInt16')
    df['Department'] = df['Department'].astype('category')
    df['DistanceFromHome'] = df['DistanceFromHome'].astype('UInt8')
    df['Education'] = df['Education'].astype('category')
    df['EducationField'] = df['EducationField'].astype('category')
    df['EmployeeCount'] = df['EmployeeCount'].astype('category')
    df['EmployeeNumber'] = df['EmployeeNumber'].astype('UInt16')
    df['EnvironmentSatisfaction'] = df['EnvironmentSatisfaction'].astype('category')
    df['Gender'] = df['Gender'].astype('category')
    df['HourlyRate'] = df['HourlyRate'].astype('UInt8')
    df['JobInvolvement'] = df['JobInvolvement'].astype('category')
    df['JobLevel'] = df['JobLevel'].astype('category')
    df['JobRole'] = df['JobRole'].astype('category')
    df['JobSatisfaction'] = df['JobSatisfaction'].astype('category')
    df['MonthlyIncome'] = df['MonthlyIncome'].astype('UInt32')
    df['MonthlyRate'] = df['MonthlyRate'].astype('UInt32')
    df['NumCompaniesWorked'] = df['NumCompaniesWorked'].astype('category')
    df['PercentSalaryHike'] = df['PercentSalaryHike'].astype('category')
    df['PerformanceRating'] = df['PerformanceRating'].astype('category')
    df['RelationshipSatisfaction'] = df['RelationshipSatisfaction'].astype('category')
    df['StandardHours'] = df['StandardHours'].astype('category')
    df['StockOptionLevel'] = df['StockOptionLevel'].astype('category')
    df['TotalWorkingYears'] = df['TotalWorkingYears'].astype('UInt8')
    df['TrainingTimesLastYear'] = df['TrainingTimesLastYear'].astype('category')
    df['WorkLifeBalance'] = df['WorkLifeBalance'].astype('category')
    df['YearsAtCompany'] = df['YearsAtCompany'].astype('UInt8')
    df['YearsInCurrentRole'] = df['YearsInCurrentRole'].astype('UInt8')
    df['YearsSinceLastPromotion'] = df['YearsSinceLastPromotion'].astype('UInt8')
    df['YearsWithCurrManager'] = df['YearsWithCurrManager'].astype('UInt8')
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