import pandas as pd
import numpy as np
import datetime as dt
import seaborn as sns

# load manager panel
manager_data=pd.read_csv("../data/manager_panel.csv.gz",index_col=0)
# load ETF panel
etf_panel=pd.read_csv("../data/etf_panel_raw.csv")

def rank_group(df,k,in_column,out_column):
    df[out_column] = df[in_column].rank(method='dense', ascending=False) <= k
    return df

# keep the top 2 ETFs by AUM in each index-quarter
etf_panel=etf_panel.groupby(['index_id','quarter']).apply(lambda x: rank_group(x,2,'aum','top2aum'))
etf_panel=etf_panel[etf_panel.top2aum]
del etf_panel['top2aum']

# list of ETF tickers
list_ETF_tickers=etf_panel.ticker.drop_duplicates().tolist()

etf_panel['etf_per_index']=etf_panel.groupby(['index_id','quarter'])['ticker'].transform('count')

# label the high-fee ETF in each index-quarter
etf_panel=etf_panel.groupby(['index_id','quarter']).apply(lambda x: rank_group(x,1,'mer_bps','high_fee'))
etf_panel['high_fee']=np.where(etf_panel['etf_per_index']==2, 1*etf_panel['high_fee'], np.nan)

# load 13F data for the ETF holdings in our sample
data13F=pd.read_csv("../data/data_13F_ETFonly_RR.csv.gz",index_col=0)

# merge 13F with manager data
data13F['year']=data13F['rdate'].apply(lambda x: float(x[0:4]))
cols_mgr=['mgrno','year','lambda_manager','mgr_duration','type','transient_investor','tax_extend']
data13F=data13F.merge(manager_data[cols_mgr],on=['mgrno','year'],how='left')

# compute ETF-level weighted average trading urgency
etf_intensity = data13F.groupby(['ticker',
                                'quarter']).apply(lambda x: 
                                 (x['lambda_manager']*x['shares']).sum()/x['shares'].sum()).reset_index()
etf_intensity=etf_intensity.rename(columns={0:'mgr_intensity'})

# compute ETF-level weighted average duration
etf_duration = data13F.groupby(['ticker',
                                'quarter']).apply(lambda x: 
                                 (x['mgr_duration']*x['shares']).sum()/x['shares'].sum()).reset_index()
etf_duration=etf_duration.rename(columns={0:'mgr_duration'})


# compute share of AUM held by tax-insensitive investors (TII)
tax_sensitivity=data13F.groupby(['ticker','quarter','tax_extend']).agg({'shares':sum,'shrout2':np.mean}).reset_index()
tax_sensitivity['total_shares_sample']=tax_sensitivity.groupby(['ticker','quarter',
                                                                ])['shares'].transform(sum)
tax_sensitivity['ratio_tii']=tax_sensitivity['shares']/tax_sensitivity['total_shares_sample']*100
tax_sensitivity=tax_sensitivity[tax_sensitivity.tax_extend=='TII']
tax_sensitivity=tax_sensitivity[['ticker','quarter','ratio_tii']]

# compute share of AUM held by transient investors (according to Bushee classification)
transient=data13F.groupby(['ticker','quarter','transient_investor']).agg({'shares':sum,'shrout2':np.mean}).reset_index()
transient['total_shares_sample']=transient.groupby(['ticker','quarter',
                                                                ])['shares'].transform(sum)
transient['ratio_tra']=transient['shares']/transient['total_shares_sample']*100
transient=transient[transient.transient_investor=='TRA']
transient=transient[['ticker','quarter','ratio_tra']]

etf_measures=etf_duration.merge(etf_intensity,on=['ticker','quarter'],how='outer')

etf_measures=etf_measures.merge(tax_sensitivity,on=['ticker','quarter'],
                                 how='outer').merge(transient,on=['ticker','quarter'],how='outer')
etf_panel=etf_panel.merge(etf_measures,on=['ticker','quarter'],how='left')


etf_panel['aum_index']=etf_panel.groupby(['index_id','quarter'])['aum'].transform(sum)
etf_panel.to_csv("../data/etf_panel_tradingrate.csv")

# get some plots on urgency
sns.histplot(data=etf_panel[etf_panel.etf_per_index==2], x='ratio_tra', hue='high_fee',common_norm=False,
             stat='probability')
sns.histplot(data=etf_panel[(etf_panel.etf_per_index==2)], x='mgr_intensity', hue='high_fee',common_norm=False,
             stat='probability',bins=40)