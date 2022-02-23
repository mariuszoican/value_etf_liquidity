### -------------------------------------------------------------------------------
# Code to graphically illustrate results in Table "Determinants of ETF competition"
### -------------------------------------------------------------------------------


import matplotlib.gridspec as gridspec
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
import statsmodels.formula.api as sm
from matplotlib import font_manager
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

# load data for all indices
data = pd.read_excel('../data/probit_data.xlsx')
data = data.set_index(['index_id'])

# control for dollar volume, relative spread, index AUM, top 3 issuer, and no. constituents
reg = sm.ols("ratio_hu~1+dvol+RelSPread_crsp+aum_ind_bn+top3_ind", data=data).fit()
# save residuals
data['ratio_hu_resid'] = reg.resid

sizefigs_L=(16,8)
gs = gridspec.GridSpec(1, 2)


fig=plt.figure(facecolor='white',figsize=sizefigs_L)

ax=fig.add_subplot(gs[0, 0])
ax=settings_plot(ax)

sns.barplot(x="sep_ind_", y="ratio_hu", palette='Paired',
            data=data,ci=95,capsize=0.2,n_boot=10000,order=[1,0])

plt.xlabel('Multi-ETF index', fontsize=20)
plt.ylabel('Index heterogeneity',fontsize=20)
ax.set_xticklabels(['Yes','No'],fontsize=20)
t1=ttest_ind(data[data.sep_ind_==1]['ratio_hu'].dropna(),
             data[data.sep_ind_==0]['ratio_hu'].dropna())
plt.title('No controls \n $H_0$: equal sub-sample means. P-value: %.3f'%t1[1],
          fontsize=20)


ax=fig.add_subplot(gs[0, 1])
ax=settings_plot(ax)

sns.barplot(x="sep_ind_", y="ratio_hu_resid", palette='Paired',
            data=data,ci=95,capsize=0.2,n_boot=10000,order=[1,0])

plt.xlabel('Multi-ETF index', fontsize=20)
plt.ylabel('Index heterogeneity',fontsize=20)
ax.set_xticklabels(['Yes','No'],fontsize=20)
t1=ttest_ind(data[data.sep_ind_==1]['ratio_hu_resid'].dropna(),
             data[data.sep_ind_==0]['ratio_hu_resid'].dropna())
plt.title('All controls \n $H_0$: equal sub-sample means. P-value: %.3f'%t1[1],
          fontsize=20)

plt.tight_layout(pad=5.0)
plt.savefig('../output/multi_index_heterogeneity.png',bbox_inches='tight')
plt.show()

