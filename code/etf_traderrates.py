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

etf_panel['uniquevals']=etf_panel.groupby(['index_id','quarter'])['mer_bps'].transform('nunique')
etf_panel['rank_fee']=etf_panel.groupby(['index_id','quarter'])['mer_bps'].rank(method='dense')

etf_panel['rank_fee']=np.where(etf_panel['uniquevals']==2, etf_panel['rank_fee'],np.nan)


etf_panel['highfee']=np.where(etf_panel['rank_fee']==1,1,
                                np.where(etf_panel['rank_fee']==2,0,np.nan))



# etf_panel=etf_panel.groupby(['index_id','quarter']).apply(lambda x: rank_group(x,1,'mer_bps','highfee'))
etf_panel['highfee']=np.where(etf_panel['etf_per_index']==2, 1*etf_panel['highfee'], np.nan)

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
# transient=data13F.groupby(['ticker','quarter','transient_investor']).agg({'shares':sum,'shrout2':np.mean}).reset_index()
# transient['total_shares_sample']=transient.groupby(['ticker','quarter',
#                                                                 ])['shares'].transform(sum)
# transient['ratio_tra']=transient['shares']/(transient['total_shares_sample'])
# transient=transient[transient.transient_investor=='TRA']
# transient=transient[['ticker','quarter','ratio_tra']]

# transient=data13F.groupby(['ticker','quarter','transient_investor']).count()['rdate'].reset_index()
# transient['total_investors']=transient.groupby(['ticker','quarter'])['rdate'].transform(sum)
# transient['ratio_tra']=transient['rdate']/transient['total_investors']
# transient=transient[transient.transient_investor=='TRA']
# transient=transient[['ticker','quarter','ratio_tra']]

transient=data13F.groupby(['ticker','quarter','transient_investor']).agg({'shares':sum,'shrout2':np.mean}).reset_index()
transient=transient.merge(etf_panel[['ticker','index_id']].drop_duplicates(),on='ticker',how='left')
transient=transient[transient.transient_investor=='TRA']
transient['index_shares']=transient.groupby(['index_id','quarter'])['shares'].transform(sum)
transient['ratio_tra']=transient['shares']/transient['index_shares']
transient=transient[['ticker','quarter','ratio_tra']]

etf_measures=etf_duration.merge(etf_intensity,on=['ticker','quarter'],how='outer')

etf_measures=etf_measures.merge(tax_sensitivity,on=['ticker','quarter'],
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

etf_panel.to_csv("../data/etf_panel_processed.csv")

# get some plots on urgency and ETF Fee
sizefigs_L=(20,8)
fig=plt.figure(facecolor='white',figsize=sizefigs_L)
gs = gridspec.GridSpec(1, 3)

ax=fig.add_subplot(gs[0, 0])
ax=settings_plot(ax)
sns.kdeplot(data=etf_panel[(etf_panel.etf_per_index==2)].dropna(subset=['highfee']), 
             x='mgr_duration', hue='highfee',common_norm=False)
plt.ylabel('Probability density',fontsize=18)
plt.xlabel('Investor stock duration',fontsize=18)

handles = [mpatches.Patch(facecolor=plt.cm.Reds(100), label="High-fee ETF"),
           mpatches.Patch(facecolor=plt.cm.Blues(100), label="Low-fee ETF")]
plt.legend(handles=handles,fontsize=18,frameon=False,loc='upper right')

ax=fig.add_subplot(gs[0, 1])
ax=settings_plot(ax)
sns.kdeplot(data=etf_panel[(etf_panel.etf_per_index==2)].dropna(subset=['highfee']), 
             x='mgr_intensity', hue='highfee',common_norm=False)
plt.ylabel('Probability density',fontsize=18)
plt.xlabel('Investor trading intensity',fontsize=18)

handles = [mpatches.Patch(facecolor=plt.cm.Reds(100), label="High-fee ETF"),
           mpatches.Patch(facecolor=plt.cm.Blues(100), label="Low-fee ETF")]
plt.legend(handles=handles,fontsize=18,frameon=False)


ax=fig.add_subplot(gs[0, 2])
ax=settings_plot(ax)
sns.kdeplot(data=etf_panel[(etf_panel.etf_per_index==2)].dropna(subset=['highfee']), 
             x='ratio_tra', hue='highfee',common_norm=False)
plt.ylabel('Probability density',fontsize=18)
plt.xlabel('Share of transient investors',fontsize=18)

handles = [mpatches.Patch(facecolor=plt.cm.Reds(100), label="High-fee ETF"),
           mpatches.Patch(facecolor=plt.cm.Blues(100), label="Low-fee ETF")]
plt.legend(handles=handles,fontsize=18,frameon=False)

plt.tight_layout(pad=2)
plt.savefig("../output/liquidityneed_by_mer.png",bbox_inches="tight")