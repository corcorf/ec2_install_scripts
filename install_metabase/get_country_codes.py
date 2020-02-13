from sqlalchemy import create_engine
import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy import inspect
print(sqlalchemy.__version__  )
import pandas as pd
import numpy as np
import os
import country_converter as coco

HOST = os.getenv('aws_pg')
PORT = '5432'
USERNAME = 'flann'
PASSWORD = os.getenv('pgpassword')
DB = 'northwind'

conn_string = f'postgres://{USERNAME}:{PASSWORD}@{HOST}:{PORT}/{DB}'

engine = create_engine(conn_string, echo=False)
tables = engine.table_names()

# look for all table-column pairs where the column name includes 'country'
inspector = inspect(engine)
tab_col_tuples = []
countries = np.array([])
for tab in tables:
    cols = inspector.get_columns(tab)
    cols = [c['name'] for c in cols]
    tab_col_tuples += [(tab,c) for c in cols if 'country' in c]

for tab, col in tab_col_tuples:
    result = engine.execute(f'SELECT {col} FROM {tab}')
    countries = np.append(countries, pd.DataFrame(result.fetchall()).iloc[:,0].unique())

countries = np.unique(countries)
countries = np.where(countries=='UK', 'United Kingdom', countries).tolist()

continents = coco.convert(names=countries, to='continent')
iso2 = coco.convert(names=countries, to='ISO2')

country_table = pd.DataFrame({'country':countries,'iso2_label':iso2,'continent':continents})
country_table.to_sql('countries', engine, if_exists='append')
