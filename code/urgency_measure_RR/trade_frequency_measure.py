import pandas as pd
import datetime as dt
import numpy as np
import statsmodels.api as sm
from statsmodels.regression.rolling import RollingOLS
from scipy.stats.mstats import winsorize
import warnings
warnings.filterwarnings('ignore')

# load raw 13F data
print("Load (raw) 13F data and CRSP data")
data13f=pd.read_csv("../../data/data_13F_RR_complete.csv.gz",index_col=0)

# load CRSP data and keep end of quarter
data_crsp=pd.read_csv("../../data/data_crsp_updateRR.csv.gz",index_col=0)
data_crsp['date']=data_crsp['date'].apply(lambda x: dt.datetime.strptime(x, "%Y-%m-%d"))
data_crsp['month']=data_crsp['date'].dt.month
data_crsp=data_crsp[data_crsp.month.isin([3,6,9,12])]
data_crsp=data_crsp.rename(columns={'prc':'prc_crsp'})
# get the price of next quarter
data_crsp['prc_crsp_nextq']=data_crsp.groupby('ticker')['prc_crsp'].shift(-1)

# keep only the last report for any given quarter
data13f=data13f.drop_duplicates(subset=['mgrno','cusip','quarter'],keep='last')

# merge CRSP and 13F data
data13f=data13f.merge(data_crsp[['ticker','quarter','prc_crsp','prc_crsp_nextq']],on=['ticker','quarter'])

# dollar position in a given stock is shares times price
data13f['dollar_position']=data13f['shares']*data13f['prc_crsp']
data13f['dollar_position_nextq']=data13f['shares']*data13f['prc_crsp_nextq']

# compute AUM by manager quarter
aum_manager_quarter=data13f.groupby(['mgrno','quarter']).sum()[['dollar_position',
                                                                'dollar_position_nextq']].reset_index()
# AUM return (with actual portfolio weights)
aum_manager_quarter['return_aum']=aum_manager_quarter.groupby('mgrno')['dollar_position'].pct_change(1)
aum_manager_quarter['return_aum_lagged']=(aum_manager_quarter['dollar_position_nextq']/
                                          aum_manager_quarter['dollar_position']-1)
aum_manager_quarter['return_aum_lagged']=aum_manager_quarter['return_aum_lagged'].shift(1)


aum_manager_quarter['return_aum_winsor']=aum_manager_quarter['return_aum'].transform(lambda x: 
                                    np.maximum(x.quantile(.025), np.minimum(x, x.quantile(.975))))
aum_manager_quarter['return_aum_lagged_winsor']=aum_manager_quarter['return_aum_lagged'].transform(lambda x: 
                                    np.maximum(x.quantile(.025), np.minimum(x, x.quantile(.975))))

# function to compute rolling regression of returns
def roll_regression(df,wndw=20):
    endog=df.return_aum_winsor
    exog=sm.add_constant(df.return_aum_lagged_winsor)
    rols = RollingOLS(endog, exog, window=wndw)
    rres = rols.fit()
    params = rres.mse_resid.map(np.sqrt)
    return params.reset_index()


# get list of managers and initialize dataframe
list_managers=aum_manager_quarter['mgrno'].drop_duplicates().tolist()
df_lambdas=pd.DataFrame()
k=0

# loop over managers to compute rolling trading intensity
for mgr in list_managers:
    k+=1
    print(k/len(list_managers)*100)
    temp=aum_manager_quarter[aum_manager_quarter.mgrno==mgr]
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
