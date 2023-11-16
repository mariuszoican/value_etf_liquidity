import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import datetime as dt
from matplotlib import cm, rcParams
from matplotlib import rc, font_manager
import matplotlib.patches as mpatches
import matplotlib.gridspec as gridspec

# Look at S&P 500 Growth ETFs: IVW and SPYG

tickers = ["IVW", "SPYG"]
tickers = ["SPYV", "VOOV"]

crsp = pd.read_csv("../data/data_crsp.csv.gz", index_col=0, parse_dates=["date"])
crsp = crsp[crsp.ticker.isin(tickers)]
crsp["return"] = crsp.groupby(["ticker"])["prc"].pct_change(1)

spreads = pd.read_csv(
    "../data/etf_spread_measures.csv", index_col=0, parse_dates=["date"]
)
spreads = spreads[spreads.ticker.isin(tickers)]
spreads["month"] = spreads["date"].apply(lambda x: dt.date(x.year, x.month, 1))
spreads = (
    spreads.groupby(["month", "ticker"])
    .mean()[["effectivespread_dollar_ave", "effectivespread_percent_ave"]]
    .reset_index()
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


sizefigs_L = (22, 10)
fig = plt.figure(facecolor="white", figsize=sizefigs_L)
gs = gridspec.GridSpec(2, 2)

# ---------
ax = fig.add_subplot(gs[0, :])
ax = settings_plot(ax)


sns.lineplot(
    data=crsp[crsp.date >= dt.datetime(2016, 1, 1)],
    x="date",
    y="prc",
    hue="ticker",
    hue_order=tickers,
)
plt.xlabel("Date", fontsize=20)
plt.ylabel("ETF closing price (US$)", fontsize=20)
plt.legend(fontsize=20, loc="best", frameon=False, title="Ticker", title_fontsize=20)

ax = fig.add_subplot(gs[1, 0])
ax = settings_plot(ax)

sns.lineplot(
    data=spreads[spreads["month"] >= dt.date(2016, 1, 1)],
    x="month",
    hue="ticker",
    y="effectivespread_dollar_ave",
    hue_order=tickers,
)

plt.xlabel("Date", fontsize=20)
plt.ylabel("Effective spread (US$)", fontsize=20)
plt.legend(fontsize=20, loc="best", frameon=False, title="Ticker", title_fontsize=20)

ax = fig.add_subplot(gs[1, 1])
ax = settings_plot(ax)

sns.lineplot(
    data=spreads[spreads["month"] >= dt.date(2016, 1, 1)],
    x="month",
    hue="ticker",
    y="effectivespread_percent_ave",
    hue_order=tickers,
)

plt.xlabel("Date", fontsize=20)
plt.ylabel("Effective spread (bps)", fontsize=20)
plt.legend(fontsize=20, loc="best", frameon=False, title="Ticker", title_fontsize=20)

plt.tight_layout(pad=4)
plt.savefig("../output/r3_comment2.png", bbox_inches="tight")

# In October 2017, SPYV NAV dropped from 116.64 to 29.56. This is a 75% drop in NAV.
# Effective spreads dropped from 3.79 cents to 0.72 cents, a 81% drop in effective spreads.
# Relative effective spreads dropped from 4.38 bps to 2.43 bps, a 45% drop in relative effective spreads.
# MER went down from 15 to 4 bps
# The split for SPYV took place on October 16, 2017.
