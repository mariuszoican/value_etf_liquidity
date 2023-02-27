import wrds
import pandas as pd

conn=wrds.Connection(wrds_username="mazoican") # login to WRDS account

print("Connection successful. Get 13F data for Thomson Reuters")

data13f=conn.raw_sql(""" SELECT * FROM tr_13f.s34 
                         WHERE fdate>='12/31/2010' """,
                         date_cols=['rdate','prdate','fdate'])

print (f"Data collected. Saving {len(data13f)} observations...")

data13f.to_csv("../../data/data_13F_updateRR.csv.gz",compression='gzip')
