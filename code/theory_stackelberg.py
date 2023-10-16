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

        if eq_stable[2] == 1:
            return eq_stable[0]
        elif eq_stable[0] < 0:
            return 0
        else:
            return np.nan

    def mktshares(self, fl, ff):
        # print ("Fee in MS:",fl, ff)

        if fl == ff:
            return np.array([1, 0])
        elif fl - ff < self.max_h():
            lm = self.lmg(fl, ff)
            # print("Marginal trader", lm)
            wL = np.exp(-lm / self.beta)
            wF = 1 - wL
            # print("Market shares: ", wL,wF)

            return np.array([wL, wF])
        else:
            return np.array([0, 1])

    def reaction_L(self, ff):
        bnd = [(ff, ff + self.max_h())]
        fL_star = sco.minimize(
            lambda x: -1000 * self.mktshares(x, ff)[0] * x,
            ff + 0.25 * self.max_h(),
            bounds=bnd,
            method="L-BFGS-B",
        )
        return np.mean(fL_star.x)

    def slope_reaction_F(self, fl):
        h = 1e-9
        return (self.reaction_F(fl + h) - self.reaction_F(fl - h)) / (2 * h)

    def reaction_F(self, fl):
        bnd = [(0, fl)]
        fF_star = sco.minimize(
            lambda x: -1000 * self.mktshares(fl, x)[1] * x,
            fl - 0.25 * self.max_h(),
            bounds=bnd,
            method="L-BFGS-B",
        )
        return np.mean(fF_star.x)

    def fixed_point(self, fees):
        # print ("Fees:", fees)
        # print(fees)
        if np.min(fees) < 0:
            return np.array([np.nan, np.nan])
        return 10**3 * np.array(
            [fees[0] - self.reaction_L(fees[1]), fees[1] - self.reaction_F(fees[0])]
        )

    def eq_fees(self):
        mth = "hybr"
        xtol = 10 ** (-9)
        initial_guess = np.array([self.beta, self.beta])
        root_finder = sco.root(
            lambda f: self.fixed_point(f),
            initial_guess.ravel(),
            tol=10 ** (-8),
            method=mth,
            options={"xtol": xtol},
        )

        if not root_finder.success:
            return np.array([np.nan, np.nan])

        mkt_shares = self.mktshares(root_finder.x[0], root_finder.x[1]).flatten()
        implied_shares = root_finder.x / root_finder.x.sum()

        return (
            np.array([np.nan, np.nan])
            if np.linalg.norm(mkt_shares - implied_shares) >= 10**-6
            else root_finder.x
        )

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

    def spreads(self, fl, ff):
        lm_eq = self.lmg(fl, ff)
        lL = np.exp(-lm_eq / self.beta) * (self.beta + lm_eq)
        lF = self.beta - lL
        sL = self.sigma * self.eta / (self.eta + lL)
        sF = self.sigma * self.eta / (self.eta + lF)
        return np.array([sL, sF])

    def turnover_shares(self, fl, ff):
        lm_eq = self.lmg(fl, ff)
        lL = np.exp(-lm_eq / self.beta) * (self.beta + lm_eq)
        lF = self.beta - lL
        return np.array([lL / self.beta, 1 - lL / self.beta])

    def eq_lmg(self):
        return self.lmg(self.eq_fees()[0], self.eq_fees()[1])


class model_stackelberg:
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

        if eq_stable[2] == 1:
            return eq_stable[0]
        elif eq_stable[0] < 0:
            return 0
        else:
            return np.nan

    def mktshares(self, fl, ff):
        # print ("Fee in MS:",fl, ff)

        if fl == ff:
            return np.array([1, 0])
        elif fl - ff < self.max_h():
            lm = self.lmg(fl, ff)
            # print("Marginal trader", lm)
            wL = np.exp(-lm / self.beta)
            wF = 1 - wL
            # print("Market shares: ", wL,wF)

            return np.array([wL, wF])
        else:
            return np.array([0, 1])

    def reaction_L(self):
        def profit(x):
            if x <= self.reaction_F(x):
                return 100000
            elif 100000 * (x - self.reaction_F(x)) >= 100000 * self.max_h():
                return 100000
            else:
                return -10000 * self.mktshares(x, self.reaction_F(x))[0] * x

        fL_star = sco.minimize(
            lambda x: profit(x),
            0.5 * self.max_h(),
            bounds=[(0, None)],
            method="Nelder-Mead",
        )
        return np.mean(fL_star.x)

    def reaction_F(self, fl):
        bnd = [(0, fl)]
        fF_star = sco.minimize(
            lambda x: -10000 * self.mktshares(fl, x)[1] * x,
            fl - 0.5 * self.max_h(),
            bounds=bnd,
            method="L-BFGS-B",
        )
        return np.mean(fF_star.x)

    def slope_reaction_F(self, fl):
        h = 1e-4
        return (self.reaction_F(fl + h) - self.reaction_F(fl - h)) / (2 * h)

    def reaction_L_stackelberg(self, x):
        return self.mktshares(x, self.reaction_F(x))[0] * x

    def eq_fees(self):
        fee_L = self.reaction_L()
        return np.array([fee_L, self.reaction_F(fee_L)])

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

    def spreads(self, fl, ff):
        lm_eq = self.lmg(fl, ff)
        lL = np.exp(-lm_eq / self.beta) * (self.beta + lm_eq)
        lF = self.beta - lL
        sL = self.sigma * self.eta / (self.eta + lL)
        sF = self.sigma * self.eta / (self.eta + lF)
        return np.array([sL, sF])

    def turnover_shares(self, fl, ff):
        lm_eq = self.lmg(fl, ff)
        lL = np.exp(-lm_eq / self.beta) * (self.beta + lm_eq)
        lF = self.beta - lL
        return np.array([lL / self.beta, 1 - lL / self.beta])

    def eq_lmg(self):
        return self.lmg(self.eq_fees()[0], self.eq_fees()[1])


# eta = 1.5
# sigma = 10
# beta_space = np.linspace(0.2, 10, 25)
# # m = model([3, eta, sigma])
# # m = model_stackelberg([3, eta, sigma])

# print("Computing fees")
# fees = np.array(
#     [model([round(betai, 1), eta, sigma]).eq_fees() for betai in beta_space]
# )
# fees_stackelberg = np.array(
#     [model_stackelberg([round(betai, 1), eta, sigma]).eq_fees() for betai in beta_space]
# )
# mktshares = np.array(
#     [
#         model_stackelberg([round(betai, 1), eta, sigma]).eq_mktshares()
#         for betai in beta_space
#     ]
# )
# max_h = np.array(
#     [model_stackelberg([round(betai, 1), eta, sigma]).max_h() for betai in beta_space]
# )


# mktshares = np.array(
#     [
#         model_stackelberg([round(betai, 1), eta, sigma]).eq_mktshares()
#         for betai in beta_space
#     ]
# )


def mshares_sim(fees):
    df = pd.DataFrame(fees)

    beta_space = np.linspace(0.2, 10, 25)
    df["beta"] = beta_space
    df.columns = ["feeH_sim", "feeL_sim", "beta"]
    df = df.dropna()

    beta_space = np.array(df["beta"].tolist())

    feesH_space = np.array(df["feeH_sim"].tolist())
    feesL_space = np.array(df["feeL_sim"].tolist())

    print("Computing market shares")
    mshares = np.array(
        [
            model([round(beta_space[k], 1), eta, sigma]).mktshares(
                feesH_space[k], feesL_space[k]
            )
            for k in range(len(beta_space))
        ]
    )
    sharesH_space = mshares[:, 0]
    sharesL_space = mshares[:, 1]

    df["wH_sim"] = sharesH_space
    df["wL_sim"] = sharesL_space

    return df


def mshares_seq(fees):
    df = pd.DataFrame(fees)

    beta_space = np.linspace(0.2, 10, 25)
    df["beta"] = beta_space
    df.columns = ["feeH_seq", "feeL_seq", "beta"]
    df = df.dropna()

    beta_space = np.array(df["beta"].tolist())

    feesH_space = np.array(df["feeH_seq"].tolist())
    feesL_space = np.array(df["feeL_seq"].tolist())

    print("Computing market shares")
    mshares = np.array(
        [
            model_stackelberg([round(beta_space[k], 1), eta, sigma]).mktshares(
                feesH_space[k], feesL_space[k]
            )
            for k in range(len(beta_space))
        ]
    )
    sharesH_space = mshares[:, 0]
    sharesL_space = mshares[:, 1]

    df["wH_seq"] = sharesH_space
    df["wL_seq"] = sharesL_space

    return df


# df_simult = mshares_sim(fees)
# df_seq = mshares_seq(fees_stackelberg)
# df_both = df_simult.merge(df_seq, on="beta")

# df_both["wH_formula_sim"] = df_both["feeH_sim"] / (
#     df_both["feeH_sim"] + df_both["feeL_sim"]
# )
# df_both["wH_formula_seq"] = df_both["feeH_seq"] / (
#     df_both["feeH_seq"] + df_both["feeL_seq"]
# )

# beta = 2
# m = model_stackelberg([beta, eta, sigma])
# profit_h = [m.mktshares(x, m.reaction_F(x))[0] * x for x in np.linspace(0, 15, 100)]
# plt.plot(np.linspace(0, 15, 100), [x.mean() for x in profit_h])


beta = 8
eta = 1.5
sigma = 1
min = 0
max = 3
m = model_stackelberg([beta, eta, sigma])
profit_h = [m.mktshares(x, m.reaction_F(x))[0] * x for x in np.linspace(min, max, 100)]
reaction_l = [m.reaction_F(x) for x in np.linspace(min, max, 100)]
plt.plot(np.linspace(min, max, 100), [x.mean() for x in profit_h])
plt.plot(np.linspace(min, max, 100), [x.mean() for x in reaction_l], c="r")
plt.axvline(m.eq_fees()[0], c="k", linestyle="--")
m.eq_fees(), m.eq_fees() / m.eq_fees().sum(), m.eq_mktshares(), m.slope_reaction_F(
    m.eq_fees()[0]
)
