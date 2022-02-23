# load data and packages
# ----------------------
import datetime as dt
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from statsmodels.regression.linear_model import OLS
from linearmodels.panel import PanelOLS
import warnings
warnings.filterwarnings('ignore')

def isnumber(x):
    try:
        float(x)
        return float(x)
    except:
        return np.nan

# load data
# -----------
data13f=pd.read_csv('../data/13FData.csv.gz') # load 13F data
data13f=data13f[data13f['fdate']==data13f['rdate']] # keep only actual report date
data13f['fdate']=data13f['fdate'].apply(lambda x: dt.datetime.strptime(str(x),"%Y%m%d"))
data13f['quarter'] = data13f['fdate'].dt.to_period('Q')

navadj=pd.read_csv('../data/NAV_adjustments.csv.gz',index_col=0) # load NAV adjustments for splits
meta=pd.read_csv('../data/all_tickers_meta.csv',index_col=0) # load meta information

navadj=navadj.rename(columns={'date':'fdate','TICKER':'ticker'})
navadj['fdate']=navadj['fdate'].apply(lambda x: dt.datetime.strptime(str(x),"%Y%m%d"))
navadj['quarter'] = navadj['fdate'].dt.to_period('Q')

data13f['year']=data13f['fdate'].apply(lambda x: x.year)
data13f=data13f[(data13f.year>=2012) & (data13f.year<=2020)]

navadj['CFACPR']=navadj.groupby('ticker')['CFACPR'].shift(-1)
navadj=navadj.drop_duplicates(subset=['ticker','quarter'],keep='last')

data13f=data13f.merge(navadj[['quarter','ticker','CFACPR']],
                              on=['quarter','ticker'],how='left')
data13f['CFACPR']=data13f['CFACPR'].fillna(1)
data13f['price_adj']=data13f['prc']/data13f['CFACPR']
data13f['shares_adj']=data13f['shares']/data13f['CFACPR']

data13f['exposure']=data13f['prc']*data13f['shares']
data13f['exposure_lag']=data13f.groupby(['ticker','mgrno'])['exposure'].shift(1)
data13f['pctchange_exposure']=(data13f.exposure-data13f.exposure_lag)/(0.5*(data13f.exposure+data13f.exposure_lag))

data13f['exposure_sh']=data13f['shares_adj']
data13f['exposure_sh_lag']=data13f.groupby(['ticker','mgrno'])['exposure_sh'].shift(1)
data13f['pctchange_exposure_sh']=(data13f.exposure_sh-
                               data13f.exposure_sh_lag)/(0.5*(data13f.exposure_sh+data13f.exposure_sh_lag))

prices=data13f.drop_duplicates(subset=['ticker','quarter'])
prices['ret']=prices.groupby(['ticker'])['price_adj'].pct_change(1)

data13f=data13f.merge(prices[['ticker','quarter','ret']],on=['ticker','quarter'],how='left')

# Estimate each manager's urgency as the slope of % flows on returns.
# ---------------------------------------------------------------------
# define a list of managers
list_managers=data13f.mgrno.drop_duplicates().tolist()

def get_urgency(manager,thr):
    temp=data13f[data13f.mgrno==manager] # select only the manager
    if len(temp)<thr:
        return np.nan
    temp = temp.set_index(['ticker', 'fdate'])
    try:
        reg = PanelOLS.from_formula('pctchange_exposure~1+ret+EntityEffects+TimeEffects', data=temp).fit()
        return abs(reg.params[1])
    except:
        return np.nan

cols_df = ['mgrno','urgency']
mgr_urg = pd.DataFrame(columns=cols_df)  # data frame for variances

print("Entered manager loop")
for manager in list_managers:
    urgency=get_urgency(manager,50)
    mgr_urg.loc[mgr_urg.shape[0]]=[manager,urgency]

mgr_urg.to_csv('../data/manager_urgency.csv')
