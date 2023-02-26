import numpy.random as npr
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import cm, rcParams
from matplotlib import rc, font_manager
import matplotlib.gridspec as gridspec
import statsmodels.formula.api as smf # load the econometrics package
import warnings
warnings.filterwarnings('ignore')
import seaborn as sns

path = "../output/"
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


def settings_plot2(ax):
    for label in ax.get_xticklabels():
        label.set_fontproperties(ticks_font)
    for label in ax.get_yticklabels():
        label.set_fontproperties(ticks_font)
    ax.spines['top'].set_visible(False)
    return ax


sizefigs_S = (8, 7)  # size of figures
sizefigs_L = (14, 6)

class investor:

    def __init__(self,params):
         
        self.l=params[0] # investor trading rate

    def trade_times(self):

        t=0
        list_times=[0]
        while t<100:
            interarrival=npr.exponential(self.l)
            list_times.append(list_times[len(list_times)-1]+interarrival)
            t=list_times[-1]
 
        def gen_weight(x):
                 wgh=npr.rand(2)
                 return np.array([round(x,2) for x in wgh/wgh.sum()])

        df=pd.DataFrame()
        df['trade_time']=np.array(list_times[:-1])
        df['inter_trade']=df['trade_time'].diff()
        df['weights']=df['trade_time'].map(gen_weight)
        df['weights'].loc[0]=np.array([0.5,0.5])
        df['weights']=df['weights'].fillna(method='ffill')

        return df
        


w=100
r, sigma = 0.001, 0.005


def return_generator(dt,r,sigma):
    return np.exp((r-0.5*sigma**2)*dt+sigma*np.sqrt(dt)*npr.randn(2))

def simulate_regression(lmbd,r,sigma):

    i=investor([1/lmbd])
    df=i.trade_times()
    df['int_time']=df['trade_time'].map(int)
    notrades=len(df)

    df_2=pd.DataFrame(columns=['int_time'])
    df_2['int_time']=range(0,100)
    df=df_2.merge(df,on='int_time',how='left')

    df['trade_time']=np.where(df['trade_time'].apply(lambda x: np.isnan(x)),df['int_time'],df['trade_time'])
    df['inter_trade']=df['trade_time'].diff()

    df['weights']=df['weights'].fillna(method='ffill')


    df['prices']=df['inter_trade'].apply(lambda dt: return_generator(dt,r,sigma))
    df['returns']=df['prices']-1
    df['prices'].iloc[0]=np.array([round(x,2) for x in np.array([w,w])])
    df['prices']=df['prices'].cumprod()

    df['weights_shift']=df['weights'].shift(1)
    df['ind_return']=df['returns']*df['weights_shift']
    df['wealth_ret']=df['ind_return'].map(sum)
    


    df_int=df.drop_duplicates(subset='int_time',keep='first')



    df_int['weights_old']=df_int['weights'].shift(1)
    df_int['returns_old']=df_int.prices.pct_change(1)
    df_int['ind_returns_old']=df_int['weights_old']*df_int['returns_old']
    df_int['wealth_shift_ret']=df_int['ind_returns_old'].map(sum)

    reg=smf.ols(data=df_int, formula='wealth_ret~wealth_shift_ret').fit()
    outcome=np.array([lmbd, reg.resid.std(), reg.rsquared_adj,notrades])

    return outcome

def simulate_regression_inflow(lmbd,r,sigma):
     
    i=investor([1/lmbd])
    df3=i.trade_times()
    del df3['weights']
    df3['int_time']=df3['trade_time'].map(int)
    df3['flow']=0.95+0.1*npr.rand(len(df3))
    df3['flow'].iloc[0]=np.nan
    

    notrades=len(df3)

    df_2=pd.DataFrame(columns=['int_time'])
    df_2['int_time']=range(0,100)
    df3=df_2.merge(df3,on='int_time',how='outer')
    df3['flow']=df3['flow'].fillna(1)

    df3['aum']=df3['flow'].cumprod()
    df3['aum'].iloc[0]=1

    df3['trade_time']=np.where(df3['trade_time'].apply(lambda x: np.isnan(x)),df3['int_time'],df3['trade_time'])
    df3['inter_trade']=df3['trade_time'].diff()

    df3['prices']=df3['inter_trade'].apply(lambda x: return_generator(x,r,sigma)[0])
    df3['prices'].iloc[0]=100
    df3['prices']=df3['prices'].cumprod()


    df3['wealth']=df3['prices']*df3['aum']

    df_int=df3.drop_duplicates(subset='int_time',keep='first')


    df_int['wealth_noflow']=df_int['prices']*df_int['aum'].shift(1)
    df_int['wealth_noflow'].iloc[0]=100    

    df_int['wealth_ret']=df_int['wealth'].pct_change(1)
    df_int['wealth_shift_ret']=df_int['wealth_noflow'].pct_change(1)

    reg=smf.ols(data=df_int, formula='wealth_ret~wealth_shift_ret').fit()
    outcome=np.array([lmbd, reg.resid.std(), reg.rsquared_adj,notrades])

    return outcome

lmbdas=npr.exponential(0.01,100000)
sims_rebalance=pd.DataFrame(columns=['lmbd','sd_resid','r2','notrades'])
sims_inflow=pd.DataFrame(columns=['lmbd','sd_resid','r2','notrades'])

k=1
for l in lmbdas:
    print(k)
    k+=1
    out_rb=simulate_regression(l,r,npr.choice([0.005]))
    out_inf=simulate_regression_inflow(l,r,npr.choice([0.005]))
    sims_rebalance.loc[len(sims_rebalance)]=list(out_rb)
    sims_inflow.loc[len(sims_inflow)]=list(out_inf)

sims_rebalance['urgency_quantile']=pd.qcut(sims_rebalance['lmbd'],5,labels=["Q1","Q2","Q3","Q4","Q5"])
sims_inflow['urgency_quantile']=pd.qcut(sims_inflow['lmbd'],5,labels=["Q1","Q2","Q3","Q4","Q5"])

sims_rebalance.to_csv("./simulation/urgency_sim_rebalance.csv")
sims_inflow.to_csv("./simulation/urgency_sim_flows.csv")

sizefigs_L=(14,10)
fig=plt.figure(facecolor='white',figsize=sizefigs_L)
gs = gridspec.GridSpec(2, 2)

# ---------
ax=fig.add_subplot(gs[0, 0])
ax=settings_plot(ax)

sns.barplot(data=sims_inflow,x='urgency_quantile',y='sd_resid', palette='mako')
plt.xlabel("Trading intensity quintile",fontsize=18)
plt.ylabel("Residual standard deviation",fontsize=18)
ax.set_xticklabels(['Low','Q2','Q3','Q4','High'],fontsize=18)
plt.title("Panel (a): Flow-induced trading",fontsize=18)

ax=fig.add_subplot(gs[0, 1])
ax=settings_plot(ax)

sns.barplot(data=sims_rebalance,x='urgency_quantile',y='sd_resid', palette='mako')
plt.xlabel("Trading intensity quintile",fontsize=18)
plt.ylabel("Residual standard deviation",fontsize=18)
ax.set_xticklabels(['Low','Q2','Q3','Q4','High'],fontsize=18)
plt.title("Panel (b): Rebalancing-induced trading",fontsize=18)

ax=fig.add_subplot(gs[1, 0])
ax=settings_plot(ax)
sns.histplot(lmbdas,stat='probability')
plt.xlabel(r"Investor arrival rate ($\lambda$)",fontsize=18)
plt.ylabel("Probability",fontsize=18)
plt.title("Panel (c): Distribution of arrival rates",fontsize=18)

ax=fig.add_subplot(gs[1, 1])
ax=settings_plot(ax)
sns.boxplot(data=sims_inflow, x='urgency_quantile', y='notrades', palette='mako')
plt.xlabel("Trading intensity quintile",fontsize=18)
plt.ylabel("Number of trades",fontsize=18)
ax.set_xticklabels(['Low','Q2','Q3','Q4','High'],fontsize=18)
plt.title("Panel (d): Trade count by arrival rate",fontsize=18)


plt.tight_layout(pad=2)
plt.savefig(path+'simulation_urgency.png',bbox_inches='tight')