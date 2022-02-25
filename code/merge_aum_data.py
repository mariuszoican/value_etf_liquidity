import pandas as pd
import numpy as np
import datetime as dt

table=pd.read_excel('../data/reg_lf_upd4.xlsx')
aum=pd.read_excel('../data/aum.xlsx')

aum_na=aum.dropna(subset=['aum'])
monthly_aum=aum_na.groupby('ticker').resample('M').last()
del monthly_aum['ticker']
monthly_aum=monthly_aum.reset_index()

def yrmth(a):
    return a.year.__str__()+a.month.__str__()

monthly_aum['yearmonth']=monthly_aum['Date'].map(yrmth)
monthly_aum['yearmonth']=monthly_aum['yearmonth'].map(int)
monthly_aum['log_aum']=monthly_aum['aum'].map(np.log)

table2=table.merge(monthly_aum[['ticker','yearmonth','aum','log_aum']],on=['ticker','yearmonth'],how='left')
table2.to_excel('../data/reg_entry_aum.xlsx')