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
plt.rcParams.update(
    {"text.usetex": True, "font.family": "sans-serif", "font.sans-serif": ["Helvetica"]}
)

sizeOfFont = 18
ticks_font = font_manager.FontProperties(size=sizeOfFont)


def settings_plot(ax):
    for label in ax.get_xticklabels():
        label.set_fontproperties(ticks_font)
    for label in ax.get_yticklabels():
        label.set_fontproperties(ticks_font)
    ax.spines["right"].set_visible(False)
    ax.spines["top"].set_visible(False)
    return ax


def settings_plot2(ax):
    for label in ax.get_xticklabels():
        label.set_fontproperties(ticks_font)
    for label in ax.get_yticklabels():
        label.set_fontproperties(ticks_font)
    ax.spines["top"].set_visible(False)
    return ax


sizefigs_S = (8, 7)  # size of figures
sizefigs_L = (14, 6)


class model:
    def __init__(self, params):
        self.alpha = params[0]
        self.eta = params[1]
        self.sigma = params[2]
        self.lh = params[3]
        self.ll = params[4]

    def L(self):  # aggregate arrival rate
        return self.alpha * self.lh + (1 - self.alpha) * self.ll

    def G0(self):
        return 2 * self.ll * self.sigma * (self.L() / (self.L() + self.eta))

    def G1(self):
        return (
            2
            * self.lh
            * self.sigma
            * (
                (self.eta / (self.eta + (1 - self.alpha) * self.ll))
                - (self.eta / (self.eta + self.alpha * self.lh))
            )
        )

    def G0_mode(self, alpha):
        L = alpha * self.lh + (1 - alpha) * self.ll
        return 2 * self.ll * self.sigma * (L / (L + self.eta))

    def G1_mode(self, alpha):
        return (
            2
            * self.lh
            * self.sigma
            * (
                (self.eta / (self.eta + (1 - alpha) * self.ll))
                - (self.eta / (self.eta + alpha * self.lh))
            )
        )

    def entry_barrier(self):
        return sco.fsolve(lambda a: self.G1_mode(a) - self.G0_mode(a), 0.5)

    def eq_fees(self):
        if self.G0() <= self.G1():
            return np.array(
                [
                    (self.G1() + (1 - self.alpha) * self.G0()) / self.alpha,
                    (self.G1() + self.G0()) / self.alpha - 2 * self.G0(),
                ]
            )
        else:
            return np.array([self.G0(), 0])

    def eq_spread(self):
        if self.G0() <= self.G1():
            return np.array(
                [
                    self.eta / (self.eta + self.alpha * self.lh),
                    self.eta / (self.eta + (1 - self.alpha) * self.ll),
                ]
            )
        else:
            return np.array([self.eta / (self.eta + self.L()), 0])

    def eq_turnover(self):
        if self.G0() <= self.G1():
            return np.array([self.alpha * self.lh, (1 - self.alpha) * self.ll])
        else:
            return np.array([self.L(), 0])


df = pd.DataFrame()

alpha_space = np.linspace(0.01, 0.99, 1000)
df["alpha"] = alpha_space

eta = 10
sigma = 1
lH = 4
ll = 1

print("Computing fees")
fees = np.array(
    [model([alphai, eta, sigma, lH, ll]).eq_fees() for alphai in alpha_space]
)
spreads = np.array(
    [model([alphai, eta, sigma, lH, ll]).eq_spread() for alphai in alpha_space]
)
entry = np.array(
    [model([alphai, eta, sigma, lH, ll]).entry_barrier() for alphai in alpha_space]
)

df["fees_L"] = fees[:, 0]
df["fees_F"] = fees[:, 1]

df["spread_L"] = spreads[:, 0]
df["spread_F"] = spreads[:, 1]

df["alpha_th"] = entry

df["fees_F"] = np.where(df["alpha"] < df["alpha_th"], np.nan, df["fees_F"])
df["spread_F"] = np.where(df["alpha"] < df["alpha_th"], np.nan, df["spread_F"])

df["fee_differential"] = df["fees_L"] - df["fees_F"]
df["spread_differential"] = df["spread_F"] - df["spread_L"]


plt.show()


sizefigs_L = (16, 6)
fig = plt.figure(facecolor="white", figsize=sizefigs_L)

gs = gridspec.GridSpec(1, 2)

# ---------
ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)

plt.plot(df["alpha"], df["fees_L"], label=r"ETF $L$ fee", c="b")
plt.plot(df["alpha"], df["fees_F"], label=r"ETF $F$ fee", c="r")
plt.plot(
    df["alpha"], df["fee_differential"], label=r"Fee differential", ls="--", c="g", lw=2
)

plt.axvline(x=df["alpha_th"].iloc[0], ls="--", c="k", lw=1)
plt.text(s=r"Follower entry", x=df["alpha_th"].iloc[-1] + 0.01, y=2.35, fontsize=16)

plt.legend(loc="best", frameon=False, fontsize=16)
plt.xlabel(r"Share of high-turnover investors ($\alpha$)", fontsize=16)
plt.ylabel(r"Equilibrium management fees", fontsize=16)


# ---------
ax = fig.add_subplot(gs[0, 1])
ax = settings_plot(ax)

plt.plot(df["alpha"], df["spread_L"], label=r"ETF $L$ half-spread", c="b")
plt.plot(df["alpha"], df["spread_F"], label=r"ETF $F$ half-spread", c="r")
plt.plot(
    df["alpha"],
    df["spread_differential"],
    label=r"Spread differential",
    ls="--",
    c="g",
    lw=2,
)

plt.axvline(x=df["alpha_th"].iloc[0], ls="--", c="k", lw=1)
plt.text(s=r"Follower entry", x=df["alpha_th"].iloc[-1] + 0.01, y=1, fontsize=16)

plt.legend(loc="best", frameon=False, fontsize=16)
plt.xlabel(r"Share of high-turnover investors ($\alpha$)", fontsize=16)
plt.ylabel(r"Equilibrium bid-ask half-spread", fontsize=16)


plt.tight_layout(pad=0.5)

plt.savefig(path + "compstat_RR2_RFS_differentials.png", bbox_inches="tight")
