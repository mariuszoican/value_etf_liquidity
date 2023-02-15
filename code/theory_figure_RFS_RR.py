import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import cm, rcParams
from matplotlib import rc, font_manager
import matplotlib.gridspec as gridspec
from scipy.special import lambertw
import scipy.optimize as sco
import warnings

warnings.filterwarnings("ignore")

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

## Figure illustrating density function
## ----------------------------------------------------
betas = [1, 1.5]


def f_phi(lmbd, beta):  # density function for investor arrival
    return 1 / beta * np.exp(-lmbd / beta)


lmbda_space = np.linspace(0, 6, 1000)

gs = gridspec.GridSpec(1, 1)
fig = plt.figure(facecolor='white', figsize=sizefigs_L)

ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)

plt.plot(lmbda_space, [f_phi(lmbdai, betas[0]) for lmbdai in lmbda_space],
         label=r"$\beta=%2.1f$" % (betas[0]), c='b', ls='-', lw=1.5)
plt.plot(lmbda_space, [f_phi(lmbdai, betas[1]) for lmbdai in lmbda_space],
         label=r"$\beta=%2.1f$" % (betas[1]), c='r', ls='--', lw=1.5)

plt.legend(loc='best', fontsize=18, frameon=False)

plt.tick_params(
    axis='x',  # changes apply to the x-axis
    which='both',  # both major and minor ticks are affected
    top=False)  # ticks along the top edge are off

plt.tick_params(
    axis='y',  # changes apply to the x-axis
    which='both',  # both major and minor ticks are affected
    right=False)  # ticks along the top edge are off

plt.xlabel(r'Investor arrival rate ($\lambda$)', fontsize=20)
plt.ylabel(r'Density: $\phi\left(\lambda \mid \beta \right)$', fontsize=20)

plt.savefig(path + "plot_density_RFS_RR.png", bbox_inches='tight')


## Figure for proof of Lemma 2 (existence of interior equilibrium)
## -------------------------------------------------------

def LL(lmg, beta):  # turnover in the low-fee fund
    return beta - np.exp(-lmg / beta) * (beta + lmg)


def LH(lmg, beta):  # turnover in the high-fee fund
    return np.exp(-lmg / beta) * (beta + lmg)


def h(eta, sigma, lmg, beta):
    return lmg * eta * sigma * (1 / (eta + LL(lmg, beta)) - 1 / (eta + LH(lmg, beta)))


# some parameters
eta = 0.1
sigma = 1
beta = 8

df_space = [0.2, 0.7]

lmg_max = -beta * (1 + lambertw(-0.5 / np.exp(1), k=-1))
lmg_space = np.linspace(0, lmg_max, 1000)
h_space = [h(eta, sigma, li, beta) for li in lmg_space]

eq_stable = sco.fsolve(lambda lmg: h(eta, sigma, lmg, beta) - df_space[0], 1)
eq_unstable = sco.fsolve(lambda lmg: h(eta, sigma, lmg, beta) - df_space[0], 10)

gs = gridspec.GridSpec(1, 1)
fig = plt.figure(facecolor='white', figsize=sizefigs_L)

ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)

plt.plot(lmg_space, h_space, label=r'$h\left(\lambda_{mg}\right)$')
plt.axhline(df_space[0], c='k', lw=2, ls='--')
plt.text(12, df_space[0] + 0.08,
         r"\noindent Interior equilibria exist: \\ $\Delta f < \max_{\lambda_{mg}} h\left(\lambda_{mg}\right)$",
         fontsize=18)

plt.axhline(df_space[1], c='k', lw=2, ls='--')
plt.text(12, df_space[1] + 0.08,
         r"\noindent No interior equilibrium: \\ $\Delta f > \max_{\lambda_{mg}} h\left(\lambda_{mg}\right)$",
         fontsize=18)

plt.scatter(eq_stable, h(eta, sigma, eq_stable, beta), c='r', s=100)
plt.text(eq_stable + 0.15, h(eta, sigma, eq_stable, beta) + 0.05, r"\noindent Stable \\ equilibrium ($\lambda^\star$)",
         fontsize=18)

plt.scatter(eq_unstable, h(eta, sigma, eq_unstable, beta), c='m', s=100, marker='s')
plt.text(eq_unstable + 0.15, h(eta, sigma, eq_unstable, beta) + 0.05,
         r"\noindent Unstable \\ equilibrium ($\lambda^\dagger$)", fontsize=18)

plt.xlabel(r"Arrival rate of the marginal investor ($\lambda_{mg}$)", fontsize=18)
plt.ylabel(r"$h\left(\lambda_{mg}\right)$", fontsize=18)
plt.ylim(0, 0.8)
plt.xlim(0, 15)
plt.savefig(path + "equilibrium_existence_RFS_RR.png", bbox_inches='tight')


class model:

    def __init__(self, params):
        self.beta = params[0]
        self.eta = params[1]
        self.sigma = params[2]

    def h(self, lm):
        sL = 1 / (self.eta + self.beta - np.exp(-lm / self.beta) * (self.beta + lm))
        sH = 1 / (self.eta + np.exp(-lm / self.beta) * (self.beta + lm))
        return lm * self.eta * self.sigma * (sL - sH)

    def max_h(self):
        lmax = sco.minimize(lambda x: -self.h(x), 0)
        return -lmax.fun

    def lmg(self, fl, ff):
        # marginal investor intensity

        eq_stable = sco.fsolve(lambda l: fl - ff - self.h(l), 0.01, full_output=1)

        if eq_stable[2]==1:
            return eq_stable[0]
        elif eq_stable[0]<0:
            return 0
        else:
            return np.nan

    def mktshares(self, fl, ff):
        # print ("Fee in MS:",fl, ff)

        if fl==ff:
            return np.array([1,0])
        elif fl-ff<self.max_h():
            lm = self.lmg(fl, ff)
            # print("Marginal trader", lm)
            wL = np.exp(-lm / self.beta)
            wF = 1 - wL
            # print("Market shares: ", wL,wF)

            return np.array([wL,wF])
        else: 
            return np.array([0,1])



    def reaction_L(self, ff):
        bnd=[(ff,ff+self.max_h())]
        fL_star = sco.minimize(lambda x:
                               -1000*self.mktshares(x, ff)[0] * x, ff+0.25*self.max_h(),
                               bounds=bnd, method='L-BFGS-B')
        return np.mean(fL_star.x)

    def reaction_F(self, fl):
        bnd=[(0,fl)]
        fF_star = sco.minimize(lambda x:
                               -1000*self.mktshares(fl, x)[1] * x, fl-0.25*self.max_h() ,
                               bounds=bnd, method='L-BFGS-B')
        return np.mean(fF_star.x)

    def fixed_point(self, fees):
        #print ("Fees:", fees)
        # print(fees)
        if np.min(fees)<0:
            return np.array([np.nan,np.nan])
        return 10**3*np.array([fees[0] - self.reaction_L(fees[1]), fees[1] - self.reaction_F(fees[0])])

    def eq_fees(self):
        mth='hybr'
        xtol=10**(-9)
        initial_guess = np.array([self.beta, 
                                  self.beta])
        root_finder = sco.root(lambda f: self.fixed_point(f), initial_guess.ravel(), tol=10**(-8),
                                method=mth, options={'xtol':xtol})

        if root_finder.success:

            mkt_shares=self.mktshares(root_finder.x[0],root_finder.x[1]).flatten()
            implied_shares=root_finder.x/root_finder.x.sum()

            if np.linalg.norm(mkt_shares-implied_shares)>=10**-6:
                return np.array([np.nan,np.nan])

            else:
                return root_finder.x
        else: 
            return np.array([np.nan,np.nan])

    def eq_mktshares(self):
        return self.mktshares(self.eq_fees()[0], self.eq_fees()[1])

    def eq_turnover(self):
        lm_eq = self.lmg(self.eq_fees()[0], self.eq_fees()[1])
        lL = np.exp(-lm_eq / self.beta) * (self.beta + lm_eq)
        lF = self.beta - lL
        return np.array([lL, lF])

    def eq_spreads(self):
        lL, lF = self.eq_turnover()
        sL = self.sigma * self.eta / (self.eta + lL)
        sF = self.sigma * self.eta / (self.eta + lF)
        return np.array([sL, sF])

    def spreads(self,fl,ff):
        lm_eq=self.lmg(fl,ff)
        lL = np.exp(-lm_eq / self.beta) * (self.beta + lm_eq)
        lF = self.beta - lL
        sL = self.sigma * self.eta / (self.eta + lL)
        sF = self.sigma * self.eta / (self.eta + lF)
        return np.array([sL, sF])

    def turnover_shares(self,fl,ff):
        lm_eq=self.lmg(fl,ff)
        lL = np.exp(-lm_eq / self.beta) * (self.beta + lm_eq)
        lF = self.beta - lL
        return np.array([lL/self.beta, 1-lL/self.beta])


    def eq_lmg(self):
        return self.lmg(self.eq_fees()[0], self.eq_fees()[1])





beta_space=np.linspace(0.2,10,99) 
eta=1.5
sigma=10

m=model([3,eta,sigma])

print("Computing fees")
fees=np.array([model([round(betai,1),eta,sigma]).eq_fees() for betai in beta_space])

# drop non-convergence points
df=pd.DataFrame(fees)
df['beta']=beta_space
df.columns=['feeH','feeL','beta']
df=df.dropna()

beta_space=np.array(df['beta'].tolist())

feesH_space=np.array(df['feeH'].tolist())
feesL_space=np.array(df['feeL'].tolist())

print("Computing market shares")
mshares=np.array([model([round(beta_space[k],1),eta,sigma]).mktshares(feesH_space[k],feesL_space[k]) 
                for k in range(len(beta_space))] )
sharesH_space=mshares[:,0]
sharesL_space=mshares[:,1]

print("Computing turnover shares")
tshares=np.array([model([round(beta_space[k],1),eta,sigma]).turnover_shares(feesH_space[k],feesL_space[k]) 
                for k in range(len(beta_space))] )
tsharesH_space=tshares[:,0]
tsharesL_space=tshares[:,1]


print("Computing spreads")
spreads=np.array([model([round(beta_space[k],1),eta,sigma]).spreads(feesH_space[k],feesL_space[k]) 
                for k in range(len(beta_space))] )
spreadH_space=spreads[:,0]
spreadL_space=spreads[:,1]

sizefigs_L=(18,6)
fig=plt.figure(facecolor='white',figsize=sizefigs_L)

gs = gridspec.GridSpec(1, 3)

# ---------
ax=fig.add_subplot(gs[0, 0])
ax=settings_plot(ax)

plt.plot(beta_space,sharesH_space,ls='-',c='b',label=r'AUM share of ETF $H$ (\%)',lw=2)
#plt.plot(beta_space,tsharesH_space,ls='--',c='r',label=r'Turnover share for ETH $H$ (\%)',lw=2)

plt.legend(loc='best',frameon=False,fontsize=16)
plt.xlabel(r'Investor trading urgency ($\beta$)',fontsize=16)
plt.ylabel(r'Equilibrium market share',fontsize=16)


# ---------
ax=fig.add_subplot(gs[0, 1])
ax=settings_plot(ax)

#plt.plot(beta_space,sharesH_space,ls='-',c='b',label=r'AUM share of ETF $H$ (\%)',lw=2)
plt.plot(beta_space,tsharesH_space,ls='--',c='r',label=r'Turnover share for ETH $H$ (\%)',lw=2)

plt.legend(loc='best',frameon=False,fontsize=16)
plt.xlabel(r'Investor trading urgency ($\beta$)',fontsize=16)
plt.ylabel(r'Equilibrium market share',fontsize=16)


# ---------
ax=fig.add_subplot(gs[0, 2])
ax=settings_plot(ax)

plt.plot(beta_space,np.array(feesH_space)-np.array(feesL_space),ls='-',c='r',
         label=r'$\Delta$ fee (ETF $H$ - ETF $L$)')
plt.xlabel(r'Investor trading urgency ($\beta$)',fontsize=16)
plt.ylabel(r'Equilibrium fee differential',fontsize=16)
plt.legend(loc='lower right',frameon=False,fontsize=16)
#plt.xlim(1.05,1.35)

ax2=ax.twinx()
ax2=settings_plot2(ax2)

plt.plot(beta_space,np.array(spreadL_space)-np.array(spreadH_space),ls='--',c='b',
         label=r'$\Delta$ spread (ETF $L$ - ETF $H$)')

plt.legend(loc='lower right',frameon=False,fontsize=16,bbox_to_anchor=(1,0.08))
plt.xlabel(r'Investor trading urgency ($\beta$)',fontsize=16)
plt.ylabel(r'Equilibrium spread differential',fontsize=16)
#plt.ylim(0.35,0.38)



plt.tight_layout(pad=3.0)

plt.savefig(path+'compstat_RR_RFS_differentials.png',bbox_inches='tight')
