import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm, rcParams
from matplotlib import rc, font_manager
import matplotlib.gridspec as gridspec
import scipy.optimize as sco
import warnings
warnings.filterwarnings("ignore")


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
sizefigs_L=(14,14)

params = [1, 0.75, 0.1]  # Lambda, xi, and gamma parameters


class model:

    def __init__(self, params):
        self.L = params[0]
        self.xi = params[1]
        self.gamma = params[2]

    def lmg(self, fl, ff):
        # marginal investor intensity
        zeta = 2 * self.gamma / self.xi
        return 0.5 * self.L - 0.5 * np.sqrt(self.L ** 2 - 4 * (fl - ff) / zeta)

    def mktshares(self, fl, ff):
        lm = self.lmg(fl, ff)
        wL = (np.log(self.L + self.xi) - np.log(lm)) / (np.log(self.L + self.xi) - np.log(self.L - self.xi))
        wF = 1 - wL
        return [wL, wF]

    #     def mktshares(self,fl,ff):
    #         lm=self.lmg(fl,ff)
    #         wL=1/(2*self.xi)*(self.L+self.xi-lm)
    #         wF=1-wL
    #         return [wL,wF]

    def reaction_L(self, ff):
        zeta = 2 * self.gamma / self.xi
        fL_star = sco.fminbound(lambda x:
                                -self.mktshares(x, ff)[0] * x,
                                ff + zeta * (self.L - self.xi) * self.xi, ff + zeta * self.L ** 2 / 4, full_output=1)
        return fL_star[0]

    def reaction_F(self, fl):
        zeta = 2 * self.gamma / self.xi
        fF_star = sco.fminbound(lambda x:
                                -self.mktshares(fl, x)[1] * x,
                                fl - zeta * self.L ** 2 / 4, fl - zeta * (self.L - self.xi) * self.xi, full_output=1)
        return np.maximum(0, fF_star[0])

    def fixed_point(self, fees):
        zeta = 2 * self.gamma / self.xi
        return [fees[0] - self.reaction_L(fees[1]), fees[1] - self.reaction_F(fees[0])]

    def eq_fees(self):
        initial_guess = [0, 0]
        zeta = 2 * self.gamma / self.xi
        eq_fee = sco.fsolve(lambda f: self.fixed_point(f), initial_guess)
        return eq_fee

    def eq_mktshares(self):
        return self.mktshares(self.eq_fees()[0], self.eq_fees()[1])

    def eq_turnover(self):
        lm_eq = self.lmg(self.eq_fees()[0], self.eq_fees()[1])
        lL = 1 / np.log((self.L + self.xi) / (self.L - self.xi)) * (self.L + self.xi - lm_eq)
        lF = 1 / np.log((self.L + self.xi) / (self.L - self.xi)) * (lm_eq - self.L + self.xi)
        return np.array([lL, lF])

    def eq_spreads(self):
        lL, lF = self.eq_turnover()
        sL = 2 * self.gamma * (lF) ** 2 / (lL + lF) ** 2
        sF = 2 * self.gamma * (lL) ** 2 / (lL + lF) ** 2
        return np.array([sL, sF])

    def eq_lmg(self):
        return self.lmg(self.eq_fees()[0], self.eq_fees()[1])

L=1.5
xi=1.2
gamma=0.2

xi_space=np.linspace(0.5*L+0.1,L-0.1,100)
L_space=np.linspace(xi+0.1,2*xi-0.1,100)

feesL_space=[model([L,xii,gamma]).eq_fees()[0] for xii in xi_space]
feesF_space=[model([L,xii,gamma]).eq_fees()[1] for xii in xi_space]

sharesL_space=[model([L,xii,gamma]).eq_mktshares()[0] for xii in xi_space]
sharesF_space=[model([L,xii,gamma]).eq_mktshares()[1] for xii in xi_space]

turnoverL_space=[model([L,xii,gamma]).eq_turnover()[0] for xii in xi_space]
turnoverF_space=[model([L,xii,gamma]).eq_turnover()[1] for xii in xi_space]

turnovershareL_space=[model([L,xii,gamma]).eq_turnover()[0]/model([L,xii,gamma]).eq_turnover().sum() for xii in xi_space]
turnovershareF_space=[model([L,xii,gamma]).eq_turnover()[1]/model([L,xii,gamma]).eq_turnover().sum() for xii in xi_space]

spreadL_space=[model([L,xii,gamma]).eq_spreads()[0] for xii in xi_space]
spreadF_space=[model([L,xii,gamma]).eq_spreads()[1] for xii in xi_space]

sizefigs_L=(14,6)
fig=plt.figure(facecolor='white',figsize=sizefigs_L)

gs = gridspec.GridSpec(1, 2)



# ---------
ax=fig.add_subplot(gs[0, 0])
ax=settings_plot(ax)

plt.plot(xi_space,sharesL_space,ls='-',c='b',label=r'ETF $L$',lw=2)
plt.plot(xi_space,sharesF_space,ls='--',c='r',label=r'ETF $F$',lw=2)
plt.plot(xi_space,np.array(sharesL_space)-np.array(sharesF_space),ls='-.',c='g',label=r'ETF $L$ - ETF $F$')


plt.legend(loc='best',frameon=False,fontsize=16)
plt.xlabel(r'Investor horizon heterogeneity ($\xi$)',fontsize=16)
plt.ylabel(r'Equilibrium market shares',fontsize=16)


# ---------
ax=fig.add_subplot(gs[0, 1])
ax=settings_plot(ax)

plt.plot(xi_space,np.array(feesL_space)-np.array(feesF_space),ls='-',c='r',label=r'Fee differential (ETF $L$ - ETF $F$)')
plt.xlabel(r'Investor horizon heterogeneity ($\xi$)',fontsize=16)
plt.ylabel(r'Equilibrium fee differential',fontsize=16)
plt.legend(loc='upper right',frameon=False,fontsize=16)
plt.xlim(1.05,1.35)

ax2=ax.twinx()
ax2=settings_plot2(ax2)

plt.plot(xi_space,np.array(spreadF_space)-np.array(spreadL_space),ls='--',c='b',
         label=r'Spread differential (ETF $F$ - ETF $L$)')

plt.legend(loc='upper right',frameon=False,fontsize=16,bbox_to_anchor=(1,0.92))
plt.xlabel(r'Investor horizon heterogeneity ($\xi$)',fontsize=16)
plt.ylabel(r'Equilibrium spread differential',fontsize=16)
#plt.ylim(0.35,0.38)



plt.tight_layout(pad=3.0)

plt.savefig(path+'compstat_RR2_differentials.png',bbox_inches='tight')

import scipy.integrate as integrate


def phi(L, xi, lmbda):
    temp = 1 / np.log((L + xi) / (L - xi))

    if lmbda < L - xi:
        return 0
    elif lmbda > L + xi:
        return 0
    else:
        return temp / lmbda


def Dwelfare(L, xi, gamma, G):
    mod = model([L, xi, gamma])

    lmarginal = mod.eq_lmg()
    turnover = mod.eq_turnover()

    costL = 0.5 * gamma * integrate.quad(lambda l: phi(L, xi, l), lmarginal, L + xi)[0] * (turnover[1] ** 2) / (
                turnover[1] ** 2 + turnover[0] ** 2)
    costF = 0.5 * gamma * integrate.quad(lambda l: phi(L, xi, l), L - xi, lmarginal)[0] * (turnover[0] ** 2) / (
                turnover[1] ** 2 + turnover[0] ** 2)

    return [G + costL + costF, costL, costF]

G=0.02
sizefigs_L=(12,8)
fig=plt.figure(facecolor='white',figsize=sizefigs_L)

ax=fig.add_subplot(111)
ax=settings_plot(ax)

xi_space=np.linspace(0.7*L,L-0.05,100)

DWelfare_space=[Dwelfare(L,xii,gamma,G)[0] for xii in xi_space]
DWelfare2_space=[Dwelfare(L,xii,gamma,2*G)[0] for xii in xi_space]

plt.plot(xi_space,DWelfare_space,ls='-',c='b',label=r'Low fixed cost ($\Gamma=%1.2f$)'%G)
plt.plot(xi_space,DWelfare2_space,ls='--',c='r',label=r'High fixed cost ($\Gamma=%1.2f$)'%(2*G))


plt.legend(loc='best',frameon=False,fontsize=16)
plt.xlabel(r'Investor horizon heterogeneity ($\xi$)',fontsize=16)
plt.ylabel(r'Welfare loss',fontsize=16)

plt.savefig(path+'WelfareLoss_v6_RR2.png',bbox_inches='tight')

plt.clf()
gs = gridspec.GridSpec(1, 1)


def phi(L, xi, lmbda):
    temp = 1 / np.log((L + xi) / (L - xi))

    if lmbda < L - xi:
        return 0
    elif lmbda > L + xi:
        return 0
    else:
        return temp / lmbda


L_choice = [1, 1.5]
xi_choice = [0.4, 0.6]

sizefigs_L = (14, 8)

lmbda_space = np.linspace(L_choice[0] - xi_choice[1] - 0.1, L_choice[1] + xi_choice[1], 1000)

fig = plt.figure(facecolor='white', figsize=sizefigs_L)

ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)

plt.plot(lmbda_space, [phi(L_choice[0], xi_choice[0], lmbdai) for lmbdai in lmbda_space],
         label=r"$\xi=%2.1f$" % (xi_choice[0]), c='b', ls='-', lw=1.5)
plt.plot(lmbda_space, [phi(L_choice[0], xi_choice[1], lmbdai) for lmbdai in lmbda_space],
         label=r"$\xi=%2.1f$" % (xi_choice[1]), c='r', ls='--', lw=1.5)

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
plt.ylabel(r'Density: $\phi\left(\lambda\right)$', fontsize=20)

plt.savefig(path+"RR2_Density_xi.png",bbox_inches='tight')