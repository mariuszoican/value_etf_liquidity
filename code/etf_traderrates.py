import pandas as pd
import numpy as np
import datetime as dt
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib import cm, rcParams
from matplotlib import rc, font_manager
import matplotlib.patches as  mpatches
import matplotlib.gridspec as gridspec
import statsmodels.formula.api as smf # load the econometrics package
import warnings
warnings.filterwarnings('ignore')
import seaborn as sns


plt.rcParams.update({
    "text.usetex": True,
    "font.family": "sans-serif",
    "font.sans-serif": ["Helvetica"]})

sizeOfFont = 18
ticks_font = font_manager.FontProperties(size=sizeOfFont)


def settings_plot(ax):
    for label in ax.get_xticklabels():
        label.set_fontproperties(ticks_font)
    for label in ax.get_yticklabels():
        label.set_fontproperties(ticks_font)
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)
    return ax

# load manager panel
# --------------------------
manager_data=pd.read_csv("../data/manager_panel.csv.gz",index_col=0)
# Follow Broman-Shum (2018) and keep only quasi-indexers and transient investors

# load ETF panel
# -----------------------------
etf_panel=pd.read_csv("../data/etf_panel_raw.csv")
# keep ETFs with at least 10 quarters of data, and exclude the first 2 quarters of an ETF existence
# (Broman-Shum, 2018)
etf_panel['inception']=etf_panel['inception'].apply(lambda x: dt.datetime.strptime(x, "%d/%m/%Y"))
etf_panel['inception_q']=etf_panel['inception'].dt.year*10+etf_panel['inception'].dt.quarter
etf_panel['quarter_decimal']=etf_panel['quarter'].apply(lambda x: int(x/10)+(x%10-1)/4)
etf_panel['inc_quarter_decimal']=etf_panel['inception_q'].apply(lambda x: int(x/10)+(x%10-1)/4)
etf_panel['time_existence']=etf_panel['quarter_decimal']-etf_panel['inc_quarter_decimal']
etf_panel=etf_panel[etf_panel.time_existence>0.5] # exclude first 1/2 years of existence
etf_panel['quarters_in_sample']=etf_panel.groupby('ticker')['quarter'].transform('count')
etf_panel=etf_panel[etf_panel.quarters_in_sample>=10] # keep ETFs with at least 10 quarters in sample

# keep the top 2 ETFs by AUM in each index-quarter
def rank_group(df,k,in_column,out_column):
    df[out_column] = df[in_column].rank(method='dense', ascending=False) <= k
    return df
etf_panel=etf_panel.groupby(['index_id','quarter']).apply(lambda x: rank_group(x,2,'aum','top2aum'))
etf_panel=etf_panel[etf_panel.top2aum]
del etf_panel['top2aum']


# list of ETF tickers
list_ETF_tickers=etf_panel.ticker.drop_duplicates().tolist()
etf_panel['etf_per_index']=etf_panel.groupby(['index_id','quarter'])['ticker'].transform('count')

# label the high-fee ETF in each index-quarter
etf_panel['uniquevals']=etf_panel.groupby(['index_id','quarter'])['mer_bps'].transform('nunique')
etf_panel['rank_fee']=etf_panel.groupby(['index_id','quarter'])['mer_bps'].rank(method='dense')
etf_panel['rank_fee']=np.where(etf_panel['uniquevals']==2, etf_panel['rank_fee'],np.nan)
etf_panel['highfee']=np.where(etf_panel['rank_fee']==2,1,
                                np.where(etf_panel['rank_fee']==1,0,np.nan))
etf_panel['highfee']=np.where(etf_panel['etf_per_index']==2, 1*etf_panel['highfee'], np.nan)
# etf_panel=etf_panel[etf_panel.us_index==1]

index_us=pd.read_csv("../data/indices_uslabel.csv")
etf_panel=etf_panel.merge(index_us,on='index_id',how='left') # dummy is index is US-focused

# load 13-F based duration measure (Cremers and Pareek, 2016)
# -------------------------------------------------------------------------
d13furg=pd.read_csv("../data/duration_13F_w8.csv.gz",index_col=0)
d13furg=d13furg[d13furg.ticker.isin(list_ETF_tickers)] 
d13furg=d13furg.rename(columns={'duration':'mgr_duration'})

cols_mgr=['mgrno','quarter','lambda_manager','horizon_perma','type','tax_extend']
d13furg=d13furg.merge(manager_data[cols_mgr],on=['mgrno','quarter'],how='left')
d13furg=d13furg[d13furg.horizon_perma.isin(['QIX','TRA'])]


unique_mgr_qtr=d13furg.drop_duplicates(subset=['mgrno','quarter'])
unique_mgr_qtr['quarter_count']=unique_mgr_qtr.groupby(['mgrno']).cumcount()
unique_mgr_qtr=unique_mgr_qtr[['mgrno','quarter','quarter_count']]

d13furg=d13furg.merge(unique_mgr_qtr, on=['mgrno','quarter'],how='left')
d13furg['quarter_count']=d13furg['quarter_count'].fillna(0)
d13furg=d13furg[d13furg.quarter_count>=8]

d13furg['quarter_decimal']=d13furg['quarter'].apply(lambda x: int(x/10)+(x%10-1)/4)
# first quarter of investment for that investor
d13furg['first_quarter_inv']=d13furg.groupby(['mgrno','ticker'])['quarter_decimal'].transform('first')
d13furg['time_since_first_inv']=d13furg['quarter_decimal']-d13furg['first_quarter_inv']

etf_duration = d13furg.groupby(['ticker',
                                'quarter']).apply(lambda x: 
                                 (x['mgr_duration']*x['shares']).sum()/x['shares'].sum()).reset_index()
etf_duration=etf_duration.rename(columns={0:'mgr_duration'})

etf_time_since_first = d13furg.groupby(['ticker',
                                'quarter']).apply(lambda x: 
                                 (x['time_since_first_inv']*x['shares']).sum()/x['shares'].sum()).reset_index()
etf_time_since_first=etf_time_since_first.rename(columns={0:'time_since_first'})

etf_duration=etf_duration.merge(etf_time_since_first,on=['ticker','quarter'],how='left')





# compute share of AUM held by tax-insensitive investors (TII)
tax_sensitivity=d13furg.groupby(['ticker','quarter',
                                 'tax_extend']).agg({'shares':sum}).reset_index()
tax_sensitivity['total_shares_sample']=tax_sensitivity.groupby(['ticker','quarter',
                                                                ])['shares'].transform(sum)
tax_sensitivity['ratio_tii']=tax_sensitivity['shares']/tax_sensitivity['total_shares_sample']*100
tax_sensitivity=tax_sensitivity[tax_sensitivity.tax_extend=='TII']
tax_sensitivity=tax_sensitivity[['ticker','quarter','ratio_tii']]

# compute share of AUM held by transient investors (according to Bushee classification)
transient=d13furg.groupby(['ticker','quarter','horizon_perma']).agg({'shares':sum}).reset_index()
transient['total_shares_sample']=transient.groupby(['ticker','quarter',
                                                                ])['shares'].transform(sum)
transient['ratio_tra']=transient['shares']/(transient['total_shares_sample'])
transient=transient[transient.horizon_perma=='TRA']
transient=transient[['ticker','quarter','ratio_tra']]

etf_measures=etf_duration.merge(tax_sensitivity,on=['ticker','quarter'],
                                 how='outer').merge(transient,on=['ticker','quarter'],how='outer')
etf_panel=etf_panel.merge(etf_measures,on=['ticker','quarter'],how='left')

# load StockTwits data
stock_twits=pd.read_csv("../data/stocktwits_etf.csv",index_col=0)
stock_twits['date']=stock_twits['date'].apply(lambda x: dt.datetime.strptime(x,"%Y-%m-%d"))
stock_twits['quarter']=stock_twits['date'].dt.year*10+stock_twits['date'].dt.quarter
stock_twits_q=stock_twits.groupby(['ticker','quarter']).median()['number_of_msgs'].reset_index()
stock_twits_q=stock_twits_q.rename(columns={'number_of_msgs':'stock_tweets'})

etf_panel['aum_index']=etf_panel.groupby(['index_id','quarter'])['aum'].transform(sum)
etf_panel=etf_panel.merge(stock_twits_q, on=['ticker','quarter'],how='left')
etf_panel['stock_tweets']=etf_panel['stock_tweets'].fillna(0)

# take logs since distribution has large outliers for SPY
etf_panel['stock_tweets']=etf_panel['stock_tweets'].apply(lambda x: np.log(1+x))

etf_panel['qduration']=pd.qcut(etf_panel['mgr_duration'], q=5, labels=False)+1

etf_graph=etf_panel[(etf_panel.etf_per_index==2)].dropna(subset=['highfee']).copy()

etf_graph.to_csv("../data/etf_panel_processed.csv")


from linearmodels.panel import PanelOLS
etf_graph=etf_graph.set_index(['index_id','quarter'])
etf_graph=etf_graph.dropna()
inv_dur_reg=PanelOLS.from_formula('mgr_duration~1 + EntityEffects + TimeEffects + time_existence + time_since_first ',data=etf_graph).fit()
etf_graph['dur_resid']=inv_dur_reg.resids
etf_graph['qduration']=pd.qcut(etf_graph['dur_resid'], q=5, labels=False)+1


d13furg=d13furg.merge(etf_graph.reset_index()[['ticker',
                                                     'quarter','highfee']],on=['ticker','quarter'],how='left')


test=etf_graph.reset_index().pivot(index=['index_id','quarter'],columns=['highfee'],
                                   values=['mer_bps','mgr_duration','ratio_tra'])
test['mer_diff']=test[ (      'mer_bps', 1.0)]-test[ (      'mer_bps', 0.0)]
test['mgr_duration_diff']=test[ (      'mgr_duration', 1.0)]-test[ (      'mgr_duration', 0.0)]
test['ratio_tra_diff']=test[ (      'ratio_tra', 1.0)]-test[ (      'ratio_tra', 0.0)]

test['mer_avg']=0.5*(test[ (      'mer_bps', 1.0)]+test[ (      'mer_bps', 0.0)])
test['mgr_duration_avg']=0.5*(test[ (      'mgr_duration', 1.0)]+test[ (      'mgr_duration', 0.0)])
test['ratio_tra_avg']=0.5*(test[ (      'ratio_tra', 1.0)]+test[ (      'ratio_tra', 0.0)])

test['mgr_duration_rel_diff']=test['mgr_duration_diff']/test['mgr_duration_avg']
test['ratio_tra_rel_diff']=test['ratio_tra_diff']/test['ratio_tra_avg']