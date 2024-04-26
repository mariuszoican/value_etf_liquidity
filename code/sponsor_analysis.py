from hydra import compose, initialize
from omegaconf import OmegaConf
import pandas as pd
import numpy as np
import datetime as dt
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib import cm, rcParams
from matplotlib import rc, font_manager
import matplotlib.patches as mpatches
import matplotlib.gridspec as gridspec
import statsmodels.formula.api as smf  # load the econometrics package
import warnings

warnings.filterwarnings("ignore")
from scipy.stats.mstats import winsorize
import seaborn as sns
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()

# plt.rcParams.update(
#     {"text.usetex": True, "font.family": "sans-serif", "font.sans-serif": ["Helvetica"]}
# )

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


if __name__ == "__main__":
    with initialize(version_base=None, config_path="../conf"):
        cfg = compose(config_name="config")

    data = pd.read_csv("../data/etf_panel_processed.csv", index_col=0)
    sponsor = pd.read_csv("../data/etf_issuer.csv")

    data = data.merge(sponsor[["ticker", "ISSUER"]], on="ticker", how="left")

    sizefigs_L = (14, 6)

    fig = plt.figure(facecolor="white", figsize=sizefigs_L)
    gs = gridspec.GridSpec(1, 2)

    # ---------
    ax = fig.add_subplot(gs[0, 0])
    ax = settings_plot(ax)

    sns.barplot(
        data=data[data.ISSUER.isin(["Blackrock", "SSgA", "Vanguard"])],
        x="ISSUER",
        y="highfee",
        order=["Blackrock", "SSgA", "Vanguard"],
        ax=ax,
    )
    plt.xlabel("ETF sponsor", fontsize=sizeOfFont)
    plt.ylabel("Share of high fee ETFs", fontsize=sizeOfFont)

    ax = fig.add_subplot(gs[0, 1])
    ax = settings_plot(ax)

    sns.barplot(
        data=data[data.ISSUER.isin(["Blackrock", "SSgA", "Vanguard"])],
        x="ISSUER",
        y="firstmover",
        order=["Blackrock", "SSgA", "Vanguard"],
        ax=ax,
    )
    plt.xlabel("ETF sponsor", fontsize=sizeOfFont)
    plt.ylabel("Share of first mover ETFs", fontsize=sizeOfFont)
    plt.tight_layout(pad=2)
    plt.savefig("../output/sponsor_analysis.png", bbox_inches="tight")
