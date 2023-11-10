import pandas as pd
import seaborn as sns
import numpy as np
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

# Bushee data on manager classification
mgr_classification=pd.read_csv("../../data/iiclass.csv")

def transient(x):
    if x=='TRA':
        return x
    elif x in ['QIX','DED']:
        return 'non-TRA'
    else:
        return np.nan
    
mgr_classification['transient_investor']=mgr_classification['horizon_perma'].map(transient)
mgr_classification['tax_extend']=mgr_classification.groupby('permakey')['tax_extend'].apply(lambda x: x.fillna(method='ffill'))

# Load trade frequency measure
mgr_tradefreq=pd.read_csv("../../data/trading_intensity_mgrno_RR.csv.gz",index_col=0)


# Load duration measure
mgr_duration=pd.read_csv("../../data/manager_duration_panel.csv.gz",index_col=0)
mgr_duration['year']=mgr_duration['quarter'].apply(lambda x: int(x/10))

# merge trading measure with Bushee
mgr_data=mgr_duration.merge(mgr_tradefreq, on=['mgrno','quarter'],how='left')
mgr_data=mgr_data.merge(mgr_classification,on=['mgrno','year'],how='left')


sizefigs_L=(14,5)
fig=plt.figure(facecolor='white',figsize=sizefigs_L)
gs = gridspec.GridSpec(1, 2)

ax=fig.add_subplot(gs[0, 0])
ax=settings_plot(ax)
sns.kdeplot(data=mgr_data,x='lambda_manager',hue='tax_extend',common_norm=False)
plt.ylabel('Probability density',fontsize=18)
plt.xlabel('Investor trading rate',fontsize=18)

handles = [mpatches.Patch(facecolor=plt.cm.Reds(100), label="Tax-insensitive investors"),
           mpatches.Patch(facecolor=plt.cm.Blues(100), label="Tax-sensitive investors")]
plt.legend(handles=handles,fontsize=18,frameon=False)

ax=fig.add_subplot(gs[0, 1])
ax=settings_plot(ax)
sns.kdeplot(data=mgr_data,x='lambda_manager',hue='transient_investor',common_norm=False)
plt.ylabel('Probability density',fontsize=18)
plt.xlabel('Investor trading rate',fontsize=18)

handles = [mpatches.Patch(facecolor=plt.cm.Reds(100), label="Transient investors"),
           mpatches.Patch(facecolor=plt.cm.Blues(100), label="Non-transient investors")]
plt.legend(handles=handles,fontsize=18,frameon=False)
plt.tight_layout(pad=2)
plt.savefig("../../output/tradingrate_by_tax.png",bbox_inches="tight")


sizefigs_L=(14,5)
fig=plt.figure(facecolor='white',figsize=sizefigs_L)
gs = gridspec.GridSpec(1, 2)

ax=fig.add_subplot(gs[0, 0])
ax=settings_plot(ax)
sns.kdeplot(data=mgr_data,x='mgr_duration',hue='tax_extend',common_norm=False)
plt.ylabel('Probability density',fontsize=18)
plt.xlabel('Investor duration',fontsize=18)

handles = [mpatches.Patch(facecolor=plt.cm.Reds(100), label="Tax-insensitive investors"),
           mpatches.Patch(facecolor=plt.cm.Blues(100), label="Tax-sensitive investors")]
plt.legend(handles=handles,fontsize=18,frameon=False)

ax=fig.add_subplot(gs[0, 1])
ax=settings_plot(ax)
sns.kdeplot(data=mgr_data,x='mgr_duration',hue='transient_investor',common_norm=False)
plt.ylabel('Probability density',fontsize=18)
plt.xlabel('Investor duration',fontsize=18)

handles = [mpatches.Patch(facecolor=plt.cm.Reds(100), label="Transient investors"),
           mpatches.Patch(facecolor=plt.cm.Blues(100), label="Non-transient investors")]
plt.legend(handles=handles,fontsize=18,frameon=False)
plt.tight_layout(pad=2)
plt.savefig("../../output/mgrduration_by_tax.png",bbox_inches="tight")


mgr_data.to_csv("../../data/manager_panel.csv.gz",compression='gzip')