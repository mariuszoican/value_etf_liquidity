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

mgrurg=pd.read_csv('../data/manager_urgency.csv')
fig=plt.figure(facecolor='white',figsize=(14,8))
gs = gridspec.GridSpec(1, 2)
ax=fig.add_subplot(gs[0, 0])
ax=settings_plot(ax)

sns.histplot(data=mgrurg,x='urgency',stat='probability',element='step',bins=100,shrink=1)
plt.xlabel('Investor urgency',fontsize=20)
plt.ylabel('Probability',fontsize=20)
plt.xlim(0,mgrurg['urgency'].max())

plt.title('Entire distribution',fontsize=20)

gs = gridspec.GridSpec(1, 2)
ax=fig.add_subplot(gs[0, 1])
ax=settings_plot(ax)

sns.histplot(data=mgrurg,x='urgency',stat='probability',element='step',bins=100,shrink=1)
plt.xlabel('Investor urgency',fontsize=20)
plt.ylabel('Probability',fontsize=20)
plt.xlim(0,10)

plt.title('Exclude extreme values',fontsize=20)

plt.tight_layout(pad=5.0)
plt.savefig('../output/urgency_distribution.png',bbox_inches='tight')
plt.show()