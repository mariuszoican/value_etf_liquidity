import pandas as pd
import numpy as np
import datetime as dt

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
df_tickers=pd.DataFrame(list_ETF_tickers)
df_tickers.to_csv("../data/list_tickers_etf.csv")

# label the high-fee ETF in each index-quarter
etf_panel=etf_panel.groupby(['index_id','quarter']).apply(lambda x: rank_group(x,1,'mer_bps','high_fee'))
etf_panel['high_fee']=1*etf_panel['high_fee']


# load 13F data and select only rows with ETF holdings in our sample
data13F=pd.read_csv("../data/data_13F_RR_complete.csv.gz",index_col=0)
data13F_ETF=data13F[data13F.ticker.isin(list_ETF_tickers)]
# convert report date to Python format
data13F_ETF['rdate']=data13F_ETF['rdate'].apply(lambda x: dt.datetime.strptime(x, "%Y-%m-%d"))
# get column with year-quarter
data13F_ETF['quarter']=data13F_ETF['rdate'].dt.year*10+data13F_ETF['rdate'].dt.quarter

data13F_ETF=data13F_ETF[(data13F_ETF['quarter']>=etf_panel['quarter'].min()) & 
                        (data13F_ETF['quarter']<=etf_panel['quarter'].max())]

data13F_ETF.to_csv("../data/data_13F_ETFonly_RR.csv.gz",compression='gzip')

