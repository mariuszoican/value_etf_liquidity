import pandas as pd
import datetime as dt
import numpy as np
import statsmodels.api as sm
from statsmodels.regression.rolling import RollingOLS
from scipy.stats.mstats import winsorize
import warnings
warnings.filterwarnings('ignore')

# load raw 13F data
print("Load (raw) 13F data")
data13f=pd.read_csv("../../data/data_13F_updateRR.csv.gz",index_col=0)

# convert report date to Python format
data13f['rdate']=data13f['rdate'].apply(lambda x: dt.datetime.strptime(x, "%Y-%m-%d"))
# get column with year-quarter
data13f['quarter']=data13f['rdate'].dt.year*10+data13f['rdate'].dt.quarter

# keep only the last report for any given quarter
data13f=data13f.drop_duplicates(subset=['mgrno','cusip','quarter'],keep='last')

# dollar position in a given stock is shares times price
data13f['dollar_position']=data13f['shares']*data13f['prc']

# compute lagged shareholdings
data13f['shares_lagged']=data13f.groupby(['mgrno','cusip'])['shares'].shift(1)
data13f['shares_lagged']=data13f['shares_lagged'].fillna(0)
data13f['dollar_position_lagged']=data13f['shares_lagged']*data13f['prc']

# compute AUM by manager quarter
aum_manager_quarter=data13f.groupby(['mgrno','quarter']).sum()['dollar_position'].reset_index()
# AUM return (with actual portfolio weights)
aum_manager_quarter['return_aum']=aum_manager_quarter.groupby('mgrno')['dollar_position'].pct_change(1)

# get counterfactual AUM (holding fixed at previous quarter no. of shares)
aum_manager_quarter_lagged=data13f.groupby(['mgrno','quarter']).sum()['dollar_position_lagged'].reset_index()
# compute counterfactual return, as if portfolio weights are fixed at the end of last quarter
aum_manager_quarter_lagged['return_aum_lagged']=aum_manager_quarter_lagged.groupby('mgrno')['dollar_position_lagged'].pct_change(1)

# merge actual and counterfactual return for rolling window regressions
returns_regression=aum_manager_quarter.merge(aum_manager_quarter_lagged,on=['mgrno','quarter'])
returns_regression['return_aum_lagged']=np.where(returns_regression['return_aum_lagged']==np.inf, 
                                                 np.nan, returns_regression['return_aum_lagged'])

returns_regression['return_aum_winsor']=returns_regression['return_aum'].transform(lambda x: 
                                    np.maximum(x.quantile(.01), np.minimum(x, x.quantile(.99))))
returns_regression['return_aum_lagged_winsor']=returns_regression['return_aum_lagged'].transform(lambda x: 
                                    np.maximum(x.quantile(.01), np.minimum(x, x.quantile(.99))))

# function to compute rolling regression of returns
def roll_regression(df,wndw=20):
    endog=df.return_aum_winsor
    exog=sm.add_constant(df.return_aum_lagged_winsor)
    rols = RollingOLS(endog, exog, window=wndw)
    rres = rols.fit()
    params = rres.mse_resid.map(np.sqrt)
    return params.reset_index()


# get list of managers and initialize dataframe
list_managers=returns_regression['mgrno'].drop_duplicates().tolist()
df_lambdas=pd.DataFrame()
k=0

# loop over managers to compute rolling trading intensity
for mgr in list_managers:
    k+=1
    print(k/len(list_managers)*100)
    temp=returns_regression[returns_regression.mgrno==mgr]
    if len(temp)<=20:
        continue
    df=roll_regression(temp)
    df=df.reset_index()
    del df['index']
    df['mgrno']=mgr
    df['quarter']=temp['quarter'].tolist()
    df=df.rename(columns={0:'lambda_manager'})
    df_lambdas=df_lambdas.append(df,ignore_index=True)
    del df_lambdas['level_0']

# save trading intensity file
df_lambdas.to_csv('../../data/trading_intensity_mgrno_RR.csv.gz',compression='gzip')
