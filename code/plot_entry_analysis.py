### -------------------------------------------------------------------------------
# Code to graphically illustrate results in Table "Before/After Follower Entry"
### -------------------------------------------------------------------------------


import matplotlib.gridspec as gridspec
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from linearmodels.panel import PanelOLS
from matplotlib import font_manager
from scipy.stats import ttest_ind
import datetime as dt

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

data=pd.read_excel('../regressions/excel_panels/reg_entry_aum.xlsx')


#data['fdate']=data['follow_inc_date'].apply(lambda x: dt.datetime.strptime(x,"%Y-%m-%d"))
data['fdate']=data['follow_inc_date']
data['fmonth']=data['fdate'].apply(lambda x: int(str(x.year)+str(x.month)))

match_q=data[data.yearmonth==data.fmonth][['ticker','mer_bps1','spread_bps_crsp1','log_aum']]
match_q=match_q.rename(columns={'mer_bps1':'mer_bps_entry', 'spread_bps_crsp1':'spread_bps_crsp_entry',
                                'log_aum':'log_AUM_etf_entry'})
data=data.merge(match_q,on='ticker',how='left')

# for v in ['mer_bps1','spread_bps_crsp1','log_aum']:
#     data[v+"_norm"]=data[v]/data[v+"%s"%"_entry"]

data=data.set_index(['ticker','yearmonth'])


# dependent variables
vars=['mer_bps1','mkt_share1','spread_bps_crsp1','log_aum']

# run regressions to include controls
for var in vars:
    reg=PanelOLS.from_formula("%s~1+tr_error_bps+perf_drag_bps+marketing_fee_bps+EntityEffects"%var,
                              data=data).fit(cov_type="clustered", cluster_entity=True, cluster_time=True)
    data['%s_resid_FE'%var]=reg.resids

    reg=PanelOLS.from_formula("%s~1+EntityEffects"%var,
                              data=data).fit()
    data['%s_resid_OnlyFE'%var]=reg.resids


sizefigs_L=(26,20)
gs = gridspec.GridSpec(3, 4)

# Figure Quantity

fig=plt.figure(facecolor='white',figsize=sizefigs_L)


ax=fig.add_subplot(gs[0, 0])
ax=settings_plot(ax)

vplot='mer_bps1'
vname='Leader MER'

sns.barplot(x="d_lwc", y=vplot, palette='Paired',
            data=data,ci=95,capsize=0.2,n_boot=10000,order=[0,1])

plt.xlabel('Time', fontsize=20)
plt.ylabel(vname,fontsize=20)
ax.set_xticklabels(['Before entry','After entry'],fontsize=20)
t1=ttest_ind(data[data.d_lwc==1][vplot].dropna(),
             data[data.d_lwc==0][vplot].dropna())
plt.title('No controls \n $H_0$: No difference around entry\n P-value: %.3f'%(t1[1]),
          fontsize=20)


ax=fig.add_subplot(gs[1, 0])
ax=settings_plot(ax)

vplot='mer_bps1_resid_OnlyFE'
vname='Leader MER'

sns.barplot(x="d_lwc", y=vplot, palette='Paired',
            data=data,ci=95,capsize=0.2,n_boot=10000,order=[0,1])
plt.xlabel('Time', fontsize=20)
plt.ylabel(vname,fontsize=20)
ax.set_xticklabels(['Before entry','After entry'],fontsize=20)
t1=ttest_ind(data[data.d_lwc==1][vplot].dropna(),
             data[data.d_lwc==0][vplot].dropna())
plt.title('Fixed effects \n $H_0$: No difference around entry\n P-value: %.3f'%(t1[1]),
          fontsize=20)


ax=fig.add_subplot(gs[2, 0])
ax=settings_plot(ax)

vplot='mer_bps1_resid_FE'
vname='Leader MER'

sns.barplot(x="d_lwc", y=vplot, palette='Paired',
            data=data,ci=95,capsize=0.2,n_boot=10000,order=[0,1])

plt.xlabel('Time', fontsize=20)
plt.ylabel(vname,fontsize=20)
ax.set_xticklabels(['Before entry','After entry'],fontsize=20)
t1=ttest_ind(data[data.d_lwc==1][vplot].dropna(),
             data[data.d_lwc==0][vplot].dropna())
plt.title('All controls \n $H_0$: No difference around entry\n P-value: %.3f'%(t1[1]),
          fontsize=20)

ax=fig.add_subplot(gs[0, 1])
ax=settings_plot(ax)

vplot='mkt_share1'
vname='Leader market share'

sns.barplot(x="d_lwc", y=vplot, palette='Paired',
            data=data,ci=95,capsize=0.2,n_boot=10000,order=[0,1])

plt.xlabel('Time', fontsize=20)
plt.ylabel(vname,fontsize=20)
ax.set_xticklabels(['Before entry','After entry'],fontsize=20)
t1=ttest_ind(data[data.d_lwc==1][vplot].dropna(),
             data[data.d_lwc==0][vplot].dropna())
plt.title('No controls \n $H_0$: No difference around entry\n P-value: %.3f'%(t1[1]),
          fontsize=20)


ax=fig.add_subplot(gs[1, 1])
ax=settings_plot(ax)

vplot='mkt_share1_resid_OnlyFE'
vname='Leader market share'


sns.barplot(x="d_lwc", y=vplot, palette='Paired',
            data=data,ci=95,capsize=0.2,n_boot=10000,order=[0,1])

plt.xlabel('Time', fontsize=20)
plt.ylabel(vname,fontsize=20)
ax.set_xticklabels(['Before entry','After entry'],fontsize=20)
t1=ttest_ind(data[data.d_lwc==1][vplot].dropna(),
             data[data.d_lwc==0][vplot].dropna())
plt.title('Fixed effects \n $H_0$: No difference around entry\n P-value: %.3f'%(t1[1]),
          fontsize=20)

ax=fig.add_subplot(gs[2, 1])
ax=settings_plot(ax)

vplot='mkt_share1_resid_FE'
vname='Leader market share'


sns.barplot(x="d_lwc", y=vplot, palette='Paired',
            data=data,ci=95,capsize=0.2,n_boot=10000,order=[0,1])

plt.xlabel('Time', fontsize=20)
plt.ylabel(vname,fontsize=20)
ax.set_xticklabels(['Before entry','After entry'],fontsize=20)
t1=ttest_ind(data[data.d_lwc==1][vplot].dropna(),
             data[data.d_lwc==0][vplot].dropna())
plt.title('All controls \n $H_0$: No difference around entry\n P-value: %.3f'%(t1[1]),
          fontsize=20)


ax=fig.add_subplot(gs[0, 2])
ax=settings_plot(ax)

vplot='spread_bps_crsp1'
vname='Leader spread'

sns.barplot(x="d_lwc", y=vplot, palette='Paired',
            data=data,ci=95,capsize=0.2,n_boot=10000,order=[0,1])

plt.xlabel('Time', fontsize=20)
plt.ylabel(vname,fontsize=20)
ax.set_xticklabels(['Before entry','After entry'],fontsize=20)
t1=ttest_ind(data[data.d_lwc==1][vplot].dropna(),
             data[data.d_lwc==0][vplot].dropna())
plt.title('No controls \n $H_0$: No difference around entry\n P-value: %.3f'%(t1[1]),
          fontsize=20)

ax=fig.add_subplot(gs[1, 2])
ax=settings_plot(ax)

vplot='spread_bps_crsp1_resid_OnlyFE'
vname='Leader spread'

sns.barplot(x="d_lwc", y=vplot, palette='Paired',
            data=data,ci=95,capsize=0.2,n_boot=10000,order=[0,1])

plt.xlabel('Time', fontsize=20)
plt.ylabel(vname,fontsize=20)
ax.set_xticklabels(['Before entry','After entry'],fontsize=20)
t1=ttest_ind(data[data.d_lwc==1][vplot].dropna(),
             data[data.d_lwc==0][vplot].dropna())
plt.title('Fixed effects \n $H_0$: No difference around entry\n P-value: %.3f'%(t1[1]),
          fontsize=20)


ax=fig.add_subplot(gs[2, 2])
ax=settings_plot(ax)

vplot='spread_bps_crsp1_resid_FE'
vname='Leader spread'

sns.barplot(x="d_lwc", y=vplot, palette='Paired',
            data=data,ci=95,capsize=0.2,n_boot=10000,order=[0,1])

plt.xlabel('Time', fontsize=20)
plt.ylabel(vname,fontsize=20)
ax.set_xticklabels(['Before entry','After entry'],fontsize=20)
t1=ttest_ind(data[data.d_lwc==1][vplot].dropna(),
             data[data.d_lwc==0][vplot].dropna())
plt.title('All controls \n $H_0$: No difference around entry\n P-value: %.3f'%(t1[1]),
          fontsize=20)


ax=fig.add_subplot(gs[0, 3])
ax=settings_plot(ax)

vplot='log_aum'
vname='Leader AUM (log)'

sns.barplot(x="d_lwc", y=vplot, palette='Paired',
            data=data,ci=95,capsize=0.2,n_boot=10000,order=[0,1])

plt.xlabel('Time', fontsize=20)
plt.ylabel(vname,fontsize=20)
ax.set_xticklabels(['Before entry','After entry'],fontsize=20)
t1=ttest_ind(data[data.d_lwc==1][vplot].dropna(),
             data[data.d_lwc==0][vplot].dropna())
plt.title('No controls \n $H_0$: No difference around entry\n P-value: %.3f'%(t1[1]),
          fontsize=20)

ax=fig.add_subplot(gs[1, 3])
ax=settings_plot(ax)

vplot='log_aum_resid_OnlyFE'
vname='Leader AUM (log)'

sns.barplot(x="d_lwc", y=vplot, palette='Paired',
            data=data,ci=95,capsize=0.2,n_boot=10000,order=[0,1])

plt.xlabel('Time', fontsize=20)
plt.ylabel(vname,fontsize=20)
ax.set_xticklabels(['Before entry','After entry'],fontsize=20)
t1=ttest_ind(data[data.d_lwc==1][vplot].dropna(),
             data[data.d_lwc==0][vplot].dropna())
plt.title('Fixed effects \n $H_0$: No difference around entry\n P-value: %.3f'%(t1[1]),
          fontsize=20)


ax=fig.add_subplot(gs[2, 3])
ax=settings_plot(ax)

vplot='log_aum_resid_FE'
vname='Leader AUM (log)'

sns.barplot(x="d_lwc", y=vplot, palette='Paired',
            data=data,ci=95,capsize=0.2,n_boot=10000,order=[0,1])

plt.xlabel('Time', fontsize=20)
plt.ylabel(vname,fontsize=20)
ax.set_xticklabels(['Before entry','After entry'],fontsize=20)
t1=ttest_ind(data[data.d_lwc==1][vplot].dropna(),
             data[data.d_lwc==0][vplot].dropna())
plt.title('All controls \n $H_0$: No difference around entry\n P-value: %.3f'%(t1[1]),
          fontsize=20)


plt.tight_layout(pad=5.0)
plt.savefig('../output/entry_plot.png',bbox_inches='tight')
plt.show()