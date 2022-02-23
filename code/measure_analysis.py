import datetime as dt
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from statsmodels.regression.linear_model import OLS
from linearmodels.panel import PanelOLS
import warnings
warnings.filterwarnings('ignore')

fname='../data/13FData.csv.gz'
data=pd.read_csv(fname)
meta='../data/all_tickers_meta.csv'
meta=pd.read_csv(meta,index_col=0)
data=data.merge(meta,on='ticker',how='left')
data['leader']=np.where(data['launch_order']==1,1,0)

def q25(x):
    return x.quantile(0.25)
def q75(x):
    return x.quantile(0.75)

mgr_ugr=pd.read_csv('../data/manager_urgency.csv',index_col=0)

data=data[data['fdate']==data['rdate']]
data['year']=data['fdate'].apply(lambda x: int(x/10000))
data=data[(data.year>=2012)&(data.year<=2020)]

data=data.merge(mgr_ugr,on=['mgrno'],how='left')
data.to_csv('../data/data_13F_urgency.csv.gz',compression='gzip')

ticker_urgency=data.groupby(['ticker','fdate']).agg({'urgency':['mean','median','min','max','std',q25,q75]}).reset_index()
ticker_urgency=ticker_urgency.merge(meta[['ticker','index','d_sameind','launch_order']],on='ticker',how='left')
ticker_urgency.columns=['ticker','ticker2','fdate','urgency_mean','urgency_median','urgency_min',
                     'urgency_max','urgency_std','urgency_q25','urgency_q75','index','d_sameind','launch_order']
ticker_urgency['urgency_range']=(ticker_urgency['urgency_max']-ticker_urgency['urgency_min'])
ticker_urgency=ticker_urgency.drop_duplicates(subset=['ticker','fdate'])
del ticker_urgency['ticker2']

index_urgency=data.groupby(['index','fdate']).agg({'urgency':['mean','median','min','max','std',q25,q75]}).reset_index()
index_urgency=index_urgency.merge(meta[['index','d_sameind']],on='index',how='left')
index_urgency.columns=['index','index2','fdate','ix_urgency_mean','ix_urgency_median','ix_urgency_min',
                     'ix_urgency_max','ix_urgency_std','ix_urgency_q25','ix_urgency_q75','d_sameind']
del index_urgency['index2']
index_urgency=index_urgency.drop_duplicates(subset=['index','fdate'])

full_urgency=ticker_urgency.merge(index_urgency[['index','fdate','ix_urgency_mean','ix_urgency_median','ix_urgency_min',
                     'ix_urgency_max','ix_urgency_std','ix_urgency_q25','ix_urgency_q75']],on=['index','fdate'],how='left')

ticker_urgency.to_csv('../data/urgency_measures.csv')
index_urgency.to_csv('../data/ix_urgency_measures.csv')
full_urgency.to_csv('../data/all_urgency_measures.csv')



