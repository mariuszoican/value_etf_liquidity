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


class model_stackelberg:
    def __init__(self, params):
        self.a = params[0]

    def mktshares(self, fl, ff):
        # print ("Fee in MS:",fl, ff)

        if fl == ff:
            return np.array([1, 0])
        elif fl - ff < 1 / self.a:
            wF = 1 - np.exp(-self.a * (fl - ff))
            wL = 1 - wF
            return np.array([wL, wF])
        else:
            return np.array([0, 1])

    def reaction_F(self, fl):
        bnd = [(0, fl)]
        fF_star = sco.minimize(
            lambda x: -10000 * self.mktshares(fl, x)[1] * x,
            1 / self.a,
            bounds=bnd,
            method="L-BFGS-B",
        )
        return np.mean(fF_star.x)

    def reaction_L(self):
        def profit(x):
            if x <= self.reaction_F(x):
                return np.nan
            else:
                return -10000 * self.mktshares(x, self.reaction_F(x))[0] * x

        fL_star = sco.minimize(
            lambda x: profit(x),
            2 / self.a,
            bounds=[(0, None)],
            method="L-BFGS-B",
        )
        return np.mean(fL_star.x)

    def reaction_L_stackelberg(self, x):
        return self.mktshares(x, self.reaction_F(x))[0] * x

    def eq_fees(self):
        fee_L = self.reaction_L()
        return np.array([fee_L, self.reaction_F(fee_L)])

    def eq_mktshares(self):
        return self.mktshares(self.eq_fees()[0], self.eq_fees()[1])


a = 6
m = model_stackelberg([a])
m.eq_mktshares()
