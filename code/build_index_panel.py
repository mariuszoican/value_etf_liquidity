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
from scipy.stats.mstats import winsorize
import seaborn as sns
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()

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
probit_file=pd.read_csv("../data/probit_raw.csv")


meta=pd.read_csv("../data/all_tickers_meta.csv",index_col=0)[['ticker','index']]
meta=meta.rename(columns={'index':'index_id'})

data13f=pd.read_csv("../data/data_13F_RR_complete.csv.gz",index_col=0)
data13f=data13f[data13f['rdate'].apply(lambda x: x[0:4]=='2020')]
data13f=data13f[data13f.ticker.isin(meta['ticker'].tolist())]

data13f=data13f.merge(meta[['ticker','index_id']],on='ticker',how='left')
# Bushee data on manager classification
mgr_classification=pd.read_csv("../data/iiclass.csv")

def transient(x):
    if x=='TRA':
        return x
    elif x in ['QIX','DED']:
        return 'non-TRA'
    else:
        return np.nan
    
mgr_classification['transient_investor']=mgr_classification['horizon_perma'].map(transient)
mgr_classification['tax_extend']=mgr_classification.groupby('permakey')['tax_extend'].apply(lambda x: x.fillna(method='ffill'))

data13f=data13f.merge(mgr_classification[['mgrno','horizon_perma','tax_extend']],on='mgrno',how='left')
data13f['dollar_pos']=data13f['shares']*data13f['prc']

tax_sensitivity=data13f.groupby(['index_id', 'tax_extend']).agg({'dollar_pos':sum}).reset_index()
tax_sensitivity['total_shares_sample']=tax_sensitivity.groupby(['index_id',
                                                                ])['dollar_pos'].transform(sum)
tax_sensitivity['ratio_tii']=tax_sensitivity['dollar_pos']/tax_sensitivity['total_shares_sample']
tax_sensitivity=tax_sensitivity[tax_sensitivity.tax_extend=='TII']
tax_sensitivity=tax_sensitivity[['index_id','ratio_tii']]

transient=data13f.groupby(['index_id', 'horizon_perma']).agg({'dollar_pos':sum}).reset_index()
transient['total_shares_sample']=transient.groupby(['index_id',
                                                                ])['dollar_pos'].transform(sum)
transient['ratio_tra']=transient['dollar_pos']/transient['total_shares_sample']
transient=transient[transient.horizon_perma=='TRA']
transient=transient[['index_id','ratio_tra']]

probit_file_2=probit_file.merge(tax_sensitivity,on='index_id').merge(transient, on='index_id')
probit_file_2.to_csv("../data/probit_data_processed.csv")