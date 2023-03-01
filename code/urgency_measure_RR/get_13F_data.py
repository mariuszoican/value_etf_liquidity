import wrds
import pandas as pd
import numpy as np
import datetime as dt

conn=wrds.Connection(wrds_username="mazoican") # login to WRDS account

print("Connection successful. Get 13F data for Thomson Reuters")

data13f=conn.raw_sql(""" SELECT rdate, mgrno, mgrname, cusip, shares, ticker, prc, shrout2 FROM tr_13f.s34 
                         WHERE fdate>='12/31/2010' """,
                         date_cols=['rdate'])

print (f"Data collected. Saving {len(data13f)} observations...")

data13f=data13f.dropna(subset=['cusip','ticker'])
data13f['quarter']=data13f['rdate'].dt.year*10+data13f['rdate'].dt.quarter
data13f.to_csv('../../data/data_13F_RR_complete.csv.gz',compression='gzip')


# Get CRSP data
# ------------------
data_crsp=conn.raw_sql("""SELECT cusip, permno, date, prc FROM crsp_a_stock.msf
                          WHERE date>='3/30/2010' """, date_cols=['date'])
print (f"Data collected. Saving {len(data_crsp)} observations...")

data_crsp['prc']=np.where(data_crsp.prc<0, -data_crsp.prc, data_crsp.prc)

data_connect_crsp=conn.raw_sql("""select *
                        from crsp_a_ccm.ccm_lookup
                        """)
data_connect_crsp['permno']=data_connect_crsp['lpermno']
data_crsp=data_crsp.merge(data_connect_crsp[['permno','tic']],on='permno',how='left')
data_crsp=data_crsp.rename(columns={'tic':'ticker'})
# get column with year-quarter
data_crsp['quarter']=data_crsp['date'].dt.year*10+data_crsp['date'].dt.quarter

data_crsp.to_csv("../../data/data_crsp_updateRR.csv.gz",compression='gzip')