import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import rc, font_manager
from numpy.polynomial.polynomial import polyfit

path="../output/"
plt.rcParams.update({
    "text.usetex": True,
    "font.family": "sans-serif",
    "font.sans-serif": ["Helvetica"]})


sizeOfFont=18
ticks_font = font_manager.FontProperties(size=sizeOfFont)

def settings_plot(ax):
    for label in ax.get_xticklabels():
        label.set_fontproperties(ticks_font)
    for label in ax.get_yticklabels():
        label.set_fontproperties(ticks_font)
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)
    return ax

def settings_plot2(ax):
    for label in ax.get_xticklabels():
        label.set_fontproperties(ticks_font)
    for label in ax.get_yticklabels():
        label.set_fontproperties(ticks_font)
    ax.spines['top'].set_visible(False)
    return ax



sizefigs_S=(8,7) # size of figures
sizefigs_L=(16,18)


data=pd.read_excel('../data/cross_section2020.xlsx')

import matplotlib.gridspec as gridspec
gs = gridspec.GridSpec(2, 2)
scale_factor=10**8*0.8

fig=plt.figure(facecolor='white',figsize=sizefigs_L)
ax=fig.add_subplot(gs[0, 0])
ax=settings_plot(ax)

sc1=plt.scatter(data[data['Launched']==1]['ln(1+%ExcessSpread)'],data[data['Launched']==1]['ln(1+%ExcessMER)'],
            s=data[data['Launched']==1]['aum_ETFG']/scale_factor,c='b',marker='o', alpha=0.6, label='Launched 1st')
sc2=plt.scatter(data[data['Launched']==2]['ln(1+%ExcessSpread)'],data[data['Launched']==2]['ln(1+%ExcessMER)'],
            s=data[data['Launched']==2]['aum_ETFG']/scale_factor,c='r',marker='^', alpha=0.6, label='Launched 2nd')
sc3=plt.scatter(data[data['Launched']==3]['ln(1+%ExcessSpread)'],data[data['Launched']==3]['ln(1+%ExcessMER)'],
            s=data[data['Launched']==3]['aum_ETFG']/scale_factor,c='g',marker='>', alpha=0.6, label='Launched 3rd')

plt.xlim(-2.5,1)
plt.ylim(-1.4,0.8)

data=data.sort_values(by='ln(1+%ExcessSpread)')

b, m = polyfit(data['ln(1+%ExcessSpread)'],data['ln(1+%ExcessMER)'], 1)
plt.plot(data['ln(1+%ExcessSpread)'],b+m*data['ln(1+%ExcessSpread)'],c='k',lw=1.5,label='Line of best fit')

plt.tick_params(
    axis='x',          # changes apply to the x-axis
    which='both',      # both major and minor ticks are affected
    top=False)       # ticks along the top edge are off

plt.tick_params(
    axis='y',          # changes apply to the x-axis
    which='both',      # both major and minor ticks are affected
    right=False)       # ticks along the top edge are off

plt.xlabel(r'Excess relative spread (logs)',fontsize=20)
plt.ylabel(r'Excess MER (logs)',fontsize=20)

lgnd=plt.legend(loc='best',frameon=False,fontsize=20)

lgnd.legendHandles[1]._sizes = [100]
lgnd.legendHandles[2]._sizes = [100]
lgnd.legendHandles[3]._sizes = [100]

plt.title("(a) Panel A: ETF relative spreads and management fees",fontsize=22,pad=20)

ax=fig.add_subplot(gs[1, 0])
ax=settings_plot(ax)

sc1=plt.scatter(data[data['Launched']==1]['ln(9+%ExcessDvol)'],data[data['Launched']==1]['ln(1+%ExcessMER)'],
            s=data[data['Launched']==1]['aum_ETFG']/scale_factor,c='b',marker='o', alpha=0.6, label='Launched 1st')
sc2=plt.scatter(data[data['Launched']==2]['ln(9+%ExcessDvol)'],data[data['Launched']==2]['ln(1+%ExcessMER)'],
            s=data[data['Launched']==2]['aum_ETFG']/scale_factor,c='r',marker='^', alpha=0.6, label='Launched 2nd')
sc3=plt.scatter(data[data['Launched']==3]['ln(9+%ExcessDvol)'],data[data['Launched']==3]['ln(1+%ExcessMER)'],
            s=data[data['Launched']==3]['aum_ETFG']/scale_factor,c='g',marker='>', alpha=0.6, label='Launched 3rd')


plt.xlim(1.6,2.4)
plt.ylim(-2,1)

data=data.sort_values(by='ln(9+%ExcessDvol)')

b, m = polyfit(data['ln(9+%ExcessDvol)'],data['ln(1+%ExcessMER)'], 1)
plt.plot(data['ln(9+%ExcessDvol)'],b+m*data['ln(9+%ExcessDvol)'],c='k',lw=1.5,label='Line of best fit')

plt.tick_params(
    axis='x',          # changes apply to the x-axis
    which='both',      # both major and minor ticks are affected
    top=False)       # ticks along the top edge are off

plt.tick_params(
    axis='y',          # changes apply to the x-axis
    which='both',      # both major and minor ticks are affected
    right=False)       # ticks along the top edge are off

plt.xlabel(r'Excess dollar volume (logs)',fontsize=20)
plt.ylabel(r'Excess MER (logs)',fontsize=20)

lgnd=plt.legend(loc='best',frameon=False,fontsize=20)

lgnd.legendHandles[1]._sizes = [100]
lgnd.legendHandles[2]._sizes = [100]
lgnd.legendHandles[3]._sizes = [100]


plt.title("(c) Panel C: ETF dollar volume and management fees",fontsize=22,pad=20)

ax=fig.add_subplot(gs[0, 1])
ax=settings_plot(ax)

sc1=plt.scatter(data[data['Launched']==1]['ln(4+%ExcessTurnover)'],data[data['Launched']==1]['ln(1+%ExcessMER)'],
            s=data[data['Launched']==1]['aum_ETFG']/scale_factor,c='b',marker='o', alpha=0.6, label='Launched 1st')
sc2=plt.scatter(data[data['Launched']==2]['ln(4+%ExcessTurnover)'],data[data['Launched']==2]['ln(1+%ExcessMER)'],
            s=data[data['Launched']==2]['aum_ETFG']/scale_factor,c='r',marker='^', alpha=0.6, label='Launched 2nd')
sc3=plt.scatter(data[data['Launched']==3]['ln(4+%ExcessTurnover)'],data[data['Launched']==3]['ln(1+%ExcessMER)'],
            s=data[data['Launched']==3]['aum_ETFG']/scale_factor,c='g',marker='>', alpha=0.6, label='Launched 3rd')


plt.xlim(0.4,1.8)
plt.ylim(-2,1)

data=data.sort_values(by='ln(4+%ExcessTurnover)')

b, m = polyfit(data['ln(4+%ExcessTurnover)'],data['ln(1+%ExcessMER)'], 1)
plt.plot(data['ln(4+%ExcessTurnover)'],b+m*data['ln(4+%ExcessTurnover)'],c='k',lw=1.5,label='Line of best fit')

plt.tick_params(
    axis='x',          # changes apply to the x-axis
    which='both',      # both major and minor ticks are affected
    top=False)       # ticks along the top edge are off

plt.tick_params(
    axis='y',          # changes apply to the x-axis
    which='both',      # both major and minor ticks are affected
    right=False)       # ticks along the top edge are off

plt.xlabel(r'Excess turnover (logs)',fontsize=20)
plt.ylabel(r'Excess MER (logs)',fontsize=20)

lgnd=plt.legend(loc='best',frameon=False,fontsize=20)

lgnd.legendHandles[1]._sizes = [100]
lgnd.legendHandles[2]._sizes = [100]
lgnd.legendHandles[3]._sizes = [100]

plt.title("(b) Panel B: ETF turnover and management fees",fontsize=22,pad=20)

ax=fig.add_subplot(gs[1, 1])
ax=settings_plot(ax)

sc1=plt.scatter(data[data['Launched']==1]['ln(1+%ExcessMktShare)'],data[data['Launched']==1]['ln(1+%ExcessMER)'],
            s=data[data['Launched']==1]['aum_ETFG']/scale_factor,c='b',marker='o', alpha=0.6, label='Launched 1st')
sc2=plt.scatter(data[data['Launched']==2]['ln(1+%ExcessMktShare)'],data[data['Launched']==2]['ln(1+%ExcessMER)'],
            s=data[data['Launched']==2]['aum_ETFG']/scale_factor,c='r',marker='^', alpha=0.6, label='Launched 2nd')
sc3=plt.scatter(data[data['Launched']==3]['ln(1+%ExcessMktShare)'],data[data['Launched']==3]['ln(1+%ExcessMER)'],
            s=data[data['Launched']==3]['aum_ETFG']/scale_factor,c='g',marker='>', alpha=0.6, label='Launched 3rd')


plt.xlim(-2,1)
plt.ylim(-1.5,0.75)

data=data.sort_values(by='ln(1+%ExcessMktShare)')

b, m = polyfit(data['ln(1+%ExcessMktShare)'],data['ln(1+%ExcessMER)'], 1)
plt.plot(data['ln(1+%ExcessMktShare)'],b+m*data['ln(1+%ExcessMktShare)'],c='k',lw=1.5,label='Line of best fit')

plt.tick_params(
    axis='x',          # changes apply to the x-axis
    which='both',      # both major and minor ticks are affected
    top=False)       # ticks along the top edge are off

plt.tick_params(
    axis='y',          # changes apply to the x-axis
    which='both',      # both major and minor ticks are affected
    right=False)       # ticks along the top edge are off

plt.xlabel(r'Excess market share (logs)',fontsize=20)
plt.ylabel(r'Excess MER (logs)',fontsize=20)

lgnd=plt.legend(loc='best',frameon=False,fontsize=20)

lgnd.legendHandles[1]._sizes = [100]
lgnd.legendHandles[2]._sizes = [100]
lgnd.legendHandles[3]._sizes = [100]

plt.title("(d) Panel D: ETF market share and management fees",fontsize=22,pad=20)


plt.tight_layout(pad=5.0)




#plt.show()
plt.savefig("../output/Bubble_LiquidityMER_RR_v2.png",bbox_inches='tight')

