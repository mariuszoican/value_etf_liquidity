import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.gridspec as gridspec
import datetime as dt
from linearmodels.panel import PanelOLS
from matplotlib import rc, font_manager
from statsmodels.tsa.ar_model import AutoReg
from scipy.stats import ttest_ind
import numpy as np

def settings_plot(ax):
    for label in ax.get_xticklabels():
        label.set_fontproperties(ticks_font)
    for label in ax.get_yticklabels():
        label.set_fontproperties(ticks_font)
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)
    return ax

sizeOfFont=18
ticks_font = font_manager.FontProperties(size=sizeOfFont)

# load VIX data
vix=pd.read_csv('../data/vix.csv')
vix['date']=vix['date'].apply(lambda x: dt.datetime.strptime(str(x),"%m/%d/%Y"))
vix['quarter']=vix['date'].dt.to_period('Q')
vix_q=vix.groupby('quarter').mean()['VIX'].reset_index()
vix_q=vix_q.set_index('quarter')
mod=AutoReg(vix_q, lags=1).fit()
vix_q['vix_resid']=mod.resid
vix_q['vix_plus']=vix_q['vix_resid'].apply(lambda x: np.maximum(x,0))
vix_q['vix_minus']=vix_q['vix_resid'].apply(lambda x: -np.minimum(x,0))
vix_q=vix_q.reset_index()
vix_q['yearqtr']=vix_q['quarter'].map(str).apply(lambda x: int(x.replace("Q","")))
del vix_q['quarter']

etf=pd.read_csv('../data/etf_panel_merged.csv',index_col=0)
etf2=etf.merge(vix_q,on='yearqtr',how='left')
etf2.to_csv('../data/etf_panel_merged_vix.csv')

diff=pd.read_csv('../data/diff_leader_follower.csv',index_col=0)
diff=diff.merge(vix_q,on='yearqtr',how='left')

diff.to_csv('../data/diff_leader_follower_vix.csv')