import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.gridspec as gridspec
import datetime as dt
from linearmodels.panel import PanelOLS
from matplotlib import rc, font_manager
from scipy.stats import ttest_ind

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

ticker_urgency=pd.read_csv('../data/urgency_measures.csv',index_col=0) # read the urgency data
data=pd.read_csv('../data/data_all_controls.csv')

ticker_urgency=ticker_urgency.merge(data[['ticker','tr_error','perf_drag','lend_byAUM_bps',
                                          'marketing_fee_bps','d_UIT']], on='ticker',how='left')

ticker_urgency['fdate']=ticker_urgency['fdate'].apply(lambda x: dt.datetime.strptime(str(x),"%Y%m%d"))
ticker_urgency=ticker_urgency.set_index(['ticker','fdate'])
ticker_urgency['ratio_het_mean']=ticker_urgency['urgency_std']/ticker_urgency['urgency_mean']

ticker_multifund=ticker_urgency[ticker_urgency.d_sameind==1]

reg2b=PanelOLS.from_formula("urgency_mean~1+tr_error+perf_drag+lend_byAUM_bps+marketing_fee_bps+d_UIT+TimeEffects",
                          data=ticker_multifund).fit()
ticker_multifund['urgency_mean_resid']=reg2b.resids

sizefigs_L=(16,8)
gs = gridspec.GridSpec(1, 2)

# Figure Quantity

fig=plt.figure(facecolor='white',figsize=sizefigs_L)


ax=fig.add_subplot(gs[0, 0])
ax=settings_plot(ax)

sns.barplot(x="launch_order", y="urgency_mean", palette='Paired',
            data=ticker_multifund,ci=95,capsize=0.2,n_boot=10000,order=[1,2,3])

plt.xlabel('ETF launch order', fontsize=20)
plt.ylabel('ETF average trading urgency',fontsize=20)
ax.set_xticklabels(['First','Second','Third'],fontsize=20)
t1=ttest_ind(ticker_multifund[ticker_multifund.launch_order==1]['urgency_mean'].dropna(),
             ticker_multifund[ticker_multifund.launch_order>1]['urgency_mean'].dropna())
plt.title('No controls \n $H_0$: Equal urgency between leader and followers. \n P-value: %.3f'%t1[1],
          fontsize=20)


ax=fig.add_subplot(gs[0, 1])
ax=settings_plot(ax)

sns.barplot(x="launch_order", y="urgency_mean_resid", palette='Paired',
            data=ticker_multifund,ci=95,capsize=0.2,n_boot=10000,order=[1,2,3])

plt.xlabel('ETF launch order', fontsize=20)
plt.ylabel('ETF average trading urgency',fontsize=20)
ax.set_xticklabels(['First','Second','Third'],fontsize=20)
t1=ttest_ind(ticker_multifund[ticker_multifund.launch_order==1]['urgency_mean_resid'].dropna(),
             ticker_multifund[ticker_multifund.launch_order>1]['urgency_mean_resid'].dropna())
plt.title('All controls \n $H_0$: Equal urgency between leader and followers. \n P-value: %.3f'%t1[1],
          fontsize=20)

plt.tight_layout(pad=5.0)
plt.savefig('../output/urgency_entry_sequence.png',bbox_inches='tight')
plt.show()