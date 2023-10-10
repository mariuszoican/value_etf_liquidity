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


# load manager panel
# --------------------------
manager_data = pd.read_csv("../data/manager_panel.csv.gz", index_col=0)
probit_file = pd.read_csv("../data/ETF_probitData_byIndex.csv")


# Load ETF panel and apply Broman-Shum (2018) filters
# ----------------------------------------------------
etf_panel = pd.read_csv("../data/etf_panel_raw.csv", index_col=0)

# compute profit
etf_panel["log_profit"] = ((etf_panel["mer_bps"] / 10**4) * (etf_panel["aum"])).map(
    np.log
)

# Add dummy = 1 if index not by FTSE, MSCI, S&P, Dow Jones, NASDAQ, Russell
etf_panel = etf_panel.merge(
    probit_file[["index_id", "d_OwnIndex"]], on="index_id", how="left"
)

# compute cumulative marketing expense
etf_panel["marketing_expense"] = (
    etf_panel["marketing_fee_bps"] / 10000 * etf_panel["aum"]
)
etf_panel["cum_mktg_expense"] = etf_panel.groupby("ticker")[
    "marketing_expense"
].transform("cumsum")
etf_panel["cum_mktg_expense"] = etf_panel["cum_mktg_expense"].apply(
    lambda x: np.log(1 + x)
)


# keep ETFs with at least 10 quarters of data, and exclude the first 2 quarters of an ETF existence
# (Broman-Shum, 2018)

# convert inception day for ETF
etf_panel["inception"] = etf_panel["inception"].apply(
    lambda x: dt.datetime.strptime(x, "%d/%m/%Y")
)
# compute inception quarter and conver it to decimal format
etf_panel["inception_q"] = (
    etf_panel["inception"].dt.year * 10 + etf_panel["inception"].dt.quarter
)
etf_panel["quarter_decimal"] = etf_panel["quarter"].apply(
    lambda x: int(x / 10) + (x % 10 - 1) / 4
)
etf_panel["inc_quarter_decimal"] = etf_panel["inception_q"].apply(
    lambda x: int(x / 10) + (x % 10 - 1) / 4
)
# compute the time that ETF existed
etf_panel["time_existence"] = (
    etf_panel["quarter_decimal"] - etf_panel["inc_quarter_decimal"]
)
etf_panel = etf_panel[
    etf_panel.time_existence > 0.5
]  # FILTER: drop first 0.5 years of existence
etf_panel["quarters_in_sample"] = etf_panel.groupby("ticker")["quarter"].transform(
    "count"
)
etf_panel = etf_panel[
    etf_panel.quarters_in_sample >= 10
]  # FILTER: keep ETFs with at least 10 quarters in sample


# Keep only the top 2 ETFs by AUM in each index-quarter
def rank_group(df, k, in_column, out_column):
    df[out_column] = df[in_column].rank(method="dense", ascending=False) <= k
    return df


etf_panel = etf_panel.groupby(["index_id", "quarter"]).apply(
    lambda x: rank_group(x, 2, "aum", "top2aum")
)
etf_panel = etf_panel[etf_panel.top2aum]
del etf_panel["top2aum"]


# get list of ETF tickers
list_ETF_tickers = etf_panel.ticker.drop_duplicates().tolist()
# number of ETFs active in a quarter for an index
etf_panel["etf_per_index"] = etf_panel.groupby(["index_id", "quarter"])[
    "ticker"
].transform("count")

# label the high-fee ETF in each index-quarter
etf_panel["uniquevals"] = etf_panel.groupby(["index_id", "quarter"])[
    "mer_bps"
].transform("nunique")
etf_panel["rank_fee"] = etf_panel.groupby(["index_id", "quarter"])["mer_bps"].rank(
    method="dense"
)
etf_panel["rank_fee"] = np.where(
    etf_panel["uniquevals"] == 2, etf_panel["rank_fee"], np.nan
)
etf_panel["highfee"] = np.where(
    etf_panel["rank_fee"] == 2, 1, np.where(etf_panel["rank_fee"] == 1, 0, np.nan)
)
etf_panel["highfee"] = np.where(
    etf_panel["etf_per_index"] == 2, 1 * etf_panel["highfee"], np.nan
)

etf_panel["rank_spread"] = etf_panel.groupby(["index_id", "quarter"])[
    "spread_bps_crsp"
].rank(method="dense")
etf_panel["rank_spread"] = np.where(
    etf_panel["uniquevals"] == 2, etf_panel["rank_spread"], np.nan
)
etf_panel["highspread"] = np.where(
    etf_panel["rank_spread"] == 2, 1, np.where(etf_panel["rank_spread"] == 1, 0, np.nan)
)
etf_panel["highspread"] = np.where(
    etf_panel["etf_per_index"] == 2, 1 * etf_panel["highspread"], np.nan
)

etf_panel["rank_inception"] = etf_panel.groupby(["index_id", "quarter"])[
    "time_existence"
].rank(method="dense")
etf_panel["rank_inception"] = np.where(
    etf_panel["uniquevals"] == 2, etf_panel["rank_inception"], np.nan
)
etf_panel["firstmover"] = np.where(
    etf_panel["rank_inception"] == 2,
    1,
    np.where(etf_panel["rank_inception"] == 1, 0, np.nan),
)
etf_panel["firstmover"] = np.where(
    etf_panel["etf_per_index"] == 2, 1 * etf_panel["firstmover"], np.nan
)

# add a dummy if ETF is focused on US equities
index_us = pd.read_csv("../data/indices_uslabel.csv")
etf_panel = etf_panel.merge(
    index_us, on="index_id", how="left"
)  # dummy is index is US-focused

# add more data from WRDS ETF Global
extra_data = pd.read_csv("../data/etf_indices_dummy_wrds.csv.gz")
extra_data = extra_data[extra_data.composite_ticker.isin(list_ETF_tickers)]
extra_data["as_of_date"] = extra_data["as_of_date"].apply(
    lambda x: dt.datetime.strptime(x, "%Y-%m-%d")
)
extra_data["quarter"] = (
    extra_data["as_of_date"].dt.year * 10 + extra_data["as_of_date"].dt.quarter
)
extra_data = extra_data.drop_duplicates(
    subset=["composite_ticker", "quarter"], keep="last"
)
extra_data = extra_data.rename(columns={"composite_ticker": "ticker"})
etf_panel = etf_panel.merge(
    extra_data[
        [
            "ticker",
            "quarter",
            "issuer",
            "description",
            "primary_benchmark",
            "tax_classification",
            "is_etn",
            "asset_class",
            "category",
            "is_levered",
            "is_active",
            "creation_fee",
            "other_expenses",
            "total_expenses",
            "fee_waivers",
            "net_expenses",
            "lead_market_maker",
        ]
    ],
    on=["ticker", "quarter"],
    how="left",
)


# load 13-F based duration measure and aggregate across managers (Cremers and Pareek, 2016)
# -----------------------------------------------------------------------------------------
d13furg = pd.read_csv("../data/duration_13F.csv.gz", index_col=0)
d13furg["dollar_pos"] = d13furg["shares"] * d13furg["prc_crsp"]
d13furg = d13furg.merge(
    etf_panel[["ticker", "index_id"]].drop_duplicates(), on="ticker", how="left"
)


# compute duration measure
def weighted_avg(x):  # function to weigh duration by dollar positions
    return np.average(x["duration"], weights=x["dollar_pos"])


manager_dur = d13furg.groupby(["mgrno", "mgrname"]).apply(weighted_avg)
manager_dur = manager_dur.reset_index()
manager_dur = manager_dur.rename(columns={0: "mgr_duration"})

d13furg = d13furg.merge(manager_dur, on=["mgrno", "mgrname"])


d13furg = d13furg[d13furg.ticker.isin(list_ETF_tickers)]

cols_mgr = ["mgrno", "quarter", "horizon_perma", "type", "tax_extend"]
d13furg = d13furg.merge(manager_data[cols_mgr], on=["mgrno", "quarter"], how="left")
# Follow Broman-Shum (2018) and keep only quasi-indexers and transient investors
d13furg = d13furg[d13furg.horizon_perma.isin(["QIX", "TRA"])]

# FILTER: drop rows where institutional ownership > shares outstanding
d13furg["inst_shares"] = d13furg.groupby(["ticker", "quarter"])["shares"].transform(sum)
d13furg["weight_shares"] = d13furg["shares"] / d13furg["inst_shares"]
d13furg["weight_shares_out"] = d13furg["shares"] / (1000 * d13furg["shrout2"])
d13furg["share_ownership"] = d13furg["inst_shares"] / (1000 * d13furg["shrout2"])
d13furg = d13furg[d13furg.share_ownership < 1]

# FILTER: drop managers that existed for less than 2 years in our sample
unique_mgr_qtr = d13furg.drop_duplicates(subset=["mgrno", "quarter"])
unique_mgr_qtr["quarter_count"] = unique_mgr_qtr.groupby(["mgrno"]).cumcount()
unique_mgr_qtr = unique_mgr_qtr[["mgrno", "quarter", "quarter_count"]]
d13furg = d13furg.merge(unique_mgr_qtr, on=["mgrno", "quarter"], how="left")
d13furg["quarter_count"] = d13furg["quarter_count"].fillna(0)
d13furg = d13furg[d13furg.quarter_count >= 8]

# CONTROLS: Compute for each manager-ETF, the time since first investment
d13furg["quarter_decimal"] = d13furg["quarter"].apply(
    lambda x: int(x / 10) + (x % 10 - 1) / 4
)
# first quarter of investment for that investor
d13furg["first_quarter_inv"] = d13furg.groupby(["mgrno", "ticker"])[
    "quarter_decimal"
].transform("first")
d13furg["time_since_first_inv"] = (
    d13furg["quarter_decimal"] - d13furg["first_quarter_inv"]
)

# Aggregate duration measures into panel

# duration
etf_duration = (
    d13furg.groupby(["ticker", "quarter"])
    .apply(lambda x: (x["mgr_duration"] * x["shares"]).sum() / x["shares"].sum())
    .reset_index()
)
etf_duration = etf_duration.rename(columns={0: "mgr_duration"})

etf_duration_index = (
    d13furg.groupby(["index_id", "quarter"])
    .apply(
        lambda x: (x["mgr_duration"] * x["dollar_pos"]).sum() / x["dollar_pos"].sum()
    )
    .reset_index()
)
etf_duration_index = etf_duration_index.rename(columns={0: "mgr_duration_index"})

# duration for Tax-Insensitive Investors (TII)
etf_duration_tii = (
    d13furg[d13furg.tax_extend == "TII"]
    .groupby(["ticker", "quarter"])
    .apply(lambda x: (x["mgr_duration"] * x["shares"]).sum() / x["shares"].sum())
    .reset_index()
)
etf_duration_tii = etf_duration_tii.rename(columns={0: "mgr_duration_tii"})

# duration for Tax-Sensitive Investors (TSI)
etf_duration_tsi = (
    d13furg[d13furg.tax_extend == "TSI"]
    .groupby(["ticker", "quarter"])
    .apply(lambda x: (x["mgr_duration"] * x["shares"]).sum() / x["shares"].sum())
    .reset_index()
)
etf_duration_tsi = etf_duration_tsi.rename(columns={0: "mgr_duration_tsi"})

# average time since first investment
etf_time_since_first = (
    d13furg.groupby(["ticker", "quarter"])
    .apply(
        lambda x: (x["time_since_first_inv"] * x["shares"]).sum() / x["shares"].sum()
    )
    .reset_index()
)
etf_time_since_first = etf_time_since_first.rename(columns={0: "time_since_first"})

# put dataframes together
etf_duration = etf_duration.merge(
    etf_duration_tii, on=["ticker", "quarter"], how="left"
)
etf_duration = etf_duration.merge(
    etf_duration_tsi, on=["ticker", "quarter"], how="left"
)
etf_duration = etf_duration.merge(
    etf_time_since_first, on=["ticker", "quarter"], how="left"
)

# Compute share of AUM held by tax-insensitive investors (TII)
# --------------------------------------------------------------------

tax_sensitivity = (
    d13furg.groupby(["ticker", "quarter", "tax_extend"])
    .agg({"shares": sum})
    .reset_index()
)
tax_sensitivity["total_shares_sample"] = tax_sensitivity.groupby(
    [
        "ticker",
        "quarter",
    ]
)["shares"].transform(sum)
tax_sensitivity["ratio_tii"] = (
    tax_sensitivity["shares"] / tax_sensitivity["total_shares_sample"] * 100
)
tax_sensitivity = tax_sensitivity[tax_sensitivity.tax_extend == "TII"]
tax_sensitivity = tax_sensitivity[["ticker", "quarter", "ratio_tii"]]

# compute share of AUM held by transient investors (according to Bushee classification)
# --------------------------------------------------------------------

transient = (
    d13furg.groupby(["ticker", "quarter", "horizon_perma"])
    .agg({"shares": sum})
    .reset_index()
)
transient["total_shares_sample"] = transient.groupby(
    [
        "ticker",
        "quarter",
    ]
)[
    "shares"
].transform(sum)
transient["ratio_tra"] = transient["shares"] / (transient["total_shares_sample"])
transient = transient[transient.horizon_perma == "TRA"]
transient = transient[["ticker", "quarter", "ratio_tra"]]

transient_ix = (
    d13furg.groupby(["index_id", "quarter", "horizon_perma"])
    .agg({"dollar_pos": sum})
    .reset_index()
)
transient_ix["dollar_pos_sample"] = transient_ix.groupby(
    [
        "index_id",
        "quarter",
    ]
)[
    "dollar_pos"
].transform(sum)
transient_ix["ratio_tra_ix"] = transient_ix["dollar_pos"] / (
    transient_ix["dollar_pos_sample"]
)
transient_ix = transient_ix[transient_ix.horizon_perma == "TRA"]
transient_ix = transient_ix[["index_id", "quarter", "ratio_tra_ix"]]

# put together manager-specific measures
etf_measures = etf_duration.merge(
    tax_sensitivity, on=["ticker", "quarter"], how="outer"
).merge(transient, on=["ticker", "quarter"], how="outer")

# merge into main ETF panel
etf_panel = etf_panel.merge(etf_measures, on=["ticker", "quarter"], how="left")
etf_panel = etf_panel.merge(etf_duration_index, on=["index_id", "quarter"], how="left")
etf_panel = etf_panel.merge(transient_ix, on=["index_id", "quarter"], how="left")

# load StockTwits data
stock_twits = pd.read_csv("../data/stocktwits_etf.csv", index_col=0)
stock_twits["date"] = stock_twits["date"].apply(
    lambda x: dt.datetime.strptime(x, "%Y-%m-%d")
)
stock_twits["quarter"] = (
    stock_twits["date"].dt.year * 10 + stock_twits["date"].dt.quarter
)
stock_twits_q = (
    stock_twits.groupby(["ticker", "quarter"])
    .mean()[["number_of_msgs", "sum_of_replies", "sum_of_likes"]]
    .reset_index()
)
# stock_twits_q['stock_tweets']=(stock_twits_q['number_of_msgs']+stock_twits_q['sum_of_replies']+
#                                  stock_twits_q['sum_of_likes']).apply(lambda x: np.log(x))
stock_twits_q = stock_twits_q.rename(columns={"number_of_msgs": "stock_tweets"})

standardize = lambda x: (x - x.mean()) / x.std()
stock_twits_q["stock_tweets_raw"] = stock_twits_q["stock_tweets"]
stock_twits_q["stock_tweets"] = scaler.fit_transform(stock_twits_q[["stock_tweets"]])
# stock_twits_q['stock_tweets']=winsorize(stock_twits_q['stock_tweets'], limits=(0,0.01))


etf_panel["aum_index"] = etf_panel.groupby(["index_id", "quarter"])["aum"].transform(
    sum
)
etf_panel["log_aum_index"] = etf_panel["aum_index"].map(np.log)
etf_panel["log_aum"] = etf_panel["aum"].map(np.log)
etf_panel = etf_panel.merge(stock_twits_q, on=["ticker", "quarter"], how="left")
etf_panel["stock_tweets"] = etf_panel["stock_tweets"].fillna(0)
etf_panel["stock_tweets_raw"] = etf_panel["stock_tweets_raw"].fillna(0)

etf_panel["qduration"] = pd.qcut(etf_panel["mgr_duration"], q=5, labels=False) + 1

etf_graph = etf_panel[(etf_panel.etf_per_index == 2)].dropna(subset=["highfee"]).copy()


count_benchmarks = (
    etf_graph.groupby(["index_id", "quarter"])[
        ["primary_benchmark", "lead_market_maker"]
    ]
    .nunique()
    .reset_index()
)
count_benchmarks = count_benchmarks.rename(
    columns={"primary_benchmark": "same_benchmark", "lead_market_maker": "same_lead_mm"}
)
count_benchmarks["same_benchmark"] = 2 - count_benchmarks["same_benchmark"]
count_benchmarks["same_lead_mm"] = 2 - count_benchmarks["same_lead_mm"]

etf_graph = etf_graph.merge(count_benchmarks, on=["index_id", "quarter"], how="left")

etf_graph.to_csv("../data/etf_panel_processed.csv")


from linearmodels.panel import PanelOLS

etf_graph = etf_graph.set_index(["index_id", "quarter"])
etf_graph = etf_graph.dropna()
inv_dur_reg = PanelOLS.from_formula(
    """mgr_duration ~  EntityEffects + TimeEffects + stock_tweets + log_aum_index + lend_byAUM_bps + 
                                  marketing_fee_bps + tr_error_bps + perf_drag_bps + d_UIT + time_existence + time_since_first""",
    data=etf_graph,
).fit()
etf_graph["dur_resid"] = inv_dur_reg.resids

rat_tra_reg = PanelOLS.from_formula(
    """ratio_tra ~  EntityEffects + TimeEffects + stock_tweets + log_aum_index + lend_byAUM_bps + 
                                  marketing_fee_bps + tr_error_bps + perf_drag_bps + d_UIT + time_existence + time_since_first""",
    data=etf_graph,
).fit()
etf_graph["tra_resid"] = rat_tra_reg.resids


d13furg = d13furg.merge(
    etf_graph.reset_index()[["ticker", "quarter", "highfee"]],
    on=["ticker", "quarter"],
    how="left",
)


sizefigs_L = (18, 6)
fig = plt.figure(facecolor="white", figsize=sizefigs_L)
gs = gridspec.GridSpec(1, 2)

# ---------
ax = fig.add_subplot(gs[0, 1])
ax = settings_plot(ax)

sns.barplot(
    data=etf_graph,
    x="highfee",
    y="dur_resid",
    capsize=0.1,
    errorbar="se",
    palette="Blues",
)
plt.xlabel("ETF management fee", fontsize=18)
plt.ylabel("Residual investor holding duration", fontsize=18)
ax.set_xticklabels(["Low fee", "High fee"], fontsize=18)
plt.title("Panel (b): Investor holding duration", fontsize=18)

ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)

sns.barplot(
    data=etf_graph,
    x="highfee",
    y="tra_resid",
    capsize=0.1,
    errorbar="se",
    palette="Blues",
)
plt.xlabel("ETF management fee", fontsize=18)
plt.ylabel("Residual AUM share of transient investors", fontsize=18)
ax.set_xticklabels(["Low fee", "High fee"], fontsize=18)
plt.title("Panel (a): AUM share of transient investors", fontsize=18)

path = "../output/"

plt.tight_layout(pad=4)
plt.savefig(path + "ETF_Clienteles.png", bbox_inches="tight")

etf_graph = etf_graph.reset_index()
d13furg_micro = d13furg[
    (d13furg.ticker.isin(etf_graph.ticker.drop_duplicates().tolist()))
    & (d13furg.quarter.isin(etf_graph.quarter.drop_duplicates().tolist()))
]

aum_quarter_tax = (
    d13furg_micro.groupby(["quarter", "tax_extend", "highfee"])
    .sum()["dollar_pos"]
    .reset_index()
)
aum_quarter_tax["dollar_pos"] = aum_quarter_tax["dollar_pos"] / 10**9
aum_quarter_tax["highfee"] = np.where(
    aum_quarter_tax["highfee"] == 1, "High MER", "Low MER"
)
aum_quarter_tra = (
    d13furg_micro.groupby(["quarter", "horizon_perma", "highfee"])
    .sum()["dollar_pos"]
    .reset_index()
)
aum_quarter_tra["dollar_pos"] = aum_quarter_tra["dollar_pos"] / 10**9
aum_quarter_tra["highfee"] = np.where(
    aum_quarter_tra["highfee"] == 1, "High MER", "Low MER"
)

sizefigs_L = (16, 9)
fig = plt.figure(facecolor="white", figsize=sizefigs_L)
gs = gridspec.GridSpec(2, 2)

# ---------
ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)
sns.barplot(
    data=aum_quarter_tax,
    x="tax_extend",
    y="dollar_pos",
    hue="highfee",
    errorbar="se",
    capsize=0.05,
    palette="Blues",
)
plt.xlabel("Tax sensitivity", fontsize=18)
plt.ylabel(r"Investor holdings (US\$bn)", fontsize=18)
ax.legend(title="ETF management fee", fontsize=16, title_fontsize=18, frameon=False)

ax.set_xticklabels(["Tax insensitive", "Tax sensitive"], fontsize=18)
plt.title("Panel (a): Holdings by tax sensitivity", fontsize=18)

ax = fig.add_subplot(gs[0, 1])
ax = settings_plot(ax)
sns.barplot(
    data=aum_quarter_tra,
    x="horizon_perma",
    y="dollar_pos",
    hue="highfee",
    errorbar="se",
    capsize=0.05,
    palette="Blues",
)
plt.xlabel("Investor horizon", fontsize=18)
plt.ylabel(r"Investor holdings (US\$bn)", fontsize=18)
ax.legend(title="ETF management fee", fontsize=16, title_fontsize=18, frameon=False)

ax.set_xticklabels(["Quasi-indexers", "Transient investor"], fontsize=18)
plt.title("Panel (b): Holdings by investor horizon", fontsize=18)

ax = fig.add_subplot(gs[1, 0])
ax = settings_plot(ax)
sns.kdeplot(data=d13furg, x="mgr_duration", hue="horizon_perma", common_norm=False)
plt.xlabel("Investor holding duration", fontsize=18)
plt.ylabel("Density", fontsize=18)
ax.legend(
    title="Investor horizon",
    fontsize=16,
    title_fontsize=18,
    frameon=False,
    labels=["Transient", "Quasi-indexers"],
)
plt.title("Panel (c): Holding durations by investor horizon", fontsize=18)

ax = fig.add_subplot(gs[1, 1])
ax = settings_plot(ax)
sns.kdeplot(data=d13furg, x="mgr_duration", hue="tax_extend", common_norm=False)
plt.xlabel("Investor holding duration", fontsize=18)
plt.ylabel("Density", fontsize=18)
ax.legend(
    title="Tax sensitivity",
    fontsize=16,
    title_fontsize=18,
    frameon=False,
    labels=["Tax-insensitive", "Tax-sensitive"],
)
plt.title("Panel (d): Holding durations by tax status", fontsize=18)

plt.tight_layout(pad=4)
plt.savefig(path + "micro_sumstats.png", bbox_inches="tight")


sizefigs_L = (12, 3)
fig = plt.figure(facecolor="white", figsize=sizefigs_L)
gs = gridspec.GridSpec(1, 1)

# ---------
ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)
sns.histplot((1 / d13furg["mgr_duration"]), stat="percent", bins=20, palette="Blues")
plt.xlabel("Inverse of investor holding duration (quarters)", fontsize=18)
plt.ylabel(r"\% of the sample", fontsize=18)
plt.savefig(path + "distribution_urgency_RR.png", bbox_inches="tight")


etf_graph = etf_graph.set_index(["index_id", "quarter"])


controls = """EntityEffects + TimeEffects + stock_tweets + log_aum_index + lend_byAUM_bps + 
                                  marketing_fee_bps + tr_error_bps + perf_drag_bps + d_UIT + ratio_tii + logret_q_lag +  ret_lag_tii"""
etf_graph["ret_lag_tii"] = etf_graph["logret_q_lag"] * etf_graph["ratio_tii"]

## Controls for spreads
spread_reg = PanelOLS.from_formula(
    f"""spread_bps_crsp ~  {controls}""", data=etf_graph
).fit()
etf_graph["spread_resid"] = spread_reg.resids


## Controls for market share
mkt_reg = PanelOLS.from_formula(f"""mkt_share ~  {controls}""", data=etf_graph).fit()
etf_graph["mktshare_resid"] = mkt_reg.resids


## Controls for log volume
vol_reg = PanelOLS.from_formula(f"""log_volume ~  {controls}""", data=etf_graph).fit()
etf_graph["volume_resid"] = vol_reg.resids


## Controls for turnover
trn_reg = PanelOLS.from_formula(
    f"""turnover_frac ~  {controls}""", data=etf_graph
).fit()
etf_graph["turnover_resid"] = trn_reg.resids


sizefigs_L = (20, 12)
fig = plt.figure(facecolor="white", figsize=sizefigs_L)
gs = gridspec.GridSpec(2, 4)

# ---------
ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)

sns.barplot(
    data=etf_graph,
    x="highfee",
    y="spread_bps_crsp",
    palette="Blues",
    errorbar="se",
    capsize=0.1,
)
plt.xlabel("")
# plt.xlabel("ETF management expense ratio (MER)",fontsize=18)
plt.ylabel("Bid-ask spread (basis points)", fontsize=18)
ax.set_xticklabels(["Low MER", "High MER"], fontsize=18)
plt.title("No controls", fontsize=18)

ax = fig.add_subplot(gs[0, 1])
ax = settings_plot(ax)

sns.barplot(
    data=etf_graph,
    x="highfee",
    y="mkt_share",
    palette="Blues",
    errorbar="se",
    capsize=0.1,
)
plt.xlabel("")
# plt.xlabel("ETF management expense ratio (MER)",fontsize=18)
plt.ylabel("Market shares", fontsize=18)
ax.set_xticklabels(["Low MER", "High MER"], fontsize=18)
plt.title("No controls", fontsize=18)

ax = fig.add_subplot(gs[0, 2])
ax = settings_plot(ax)

sns.barplot(
    data=etf_graph,
    x="highfee",
    y="log_volume",
    palette="Blues",
    errorbar="se",
    capsize=0.1,
)
plt.xlabel("")
# plt.xlabel("ETF management expense ratio (MER)",fontsize=18)
plt.ylabel("Trading volume (logs)", fontsize=18)
ax.set_xticklabels(["Low MER", "High MER"], fontsize=18)
plt.title("No controls", fontsize=18)


ax = fig.add_subplot(gs[0, 3])
ax = settings_plot(ax)

sns.barplot(
    data=etf_graph,
    x="highfee",
    y="turnover_frac",
    palette="Blues",
    errorbar="se",
    capsize=0.1,
)
plt.xlabel("")
# plt.xlabel("ETF management expense ratio (MER)",fontsize=18)
plt.ylabel("Turnover", fontsize=18)
ax.set_xticklabels(["Low MER", "High MER"], fontsize=18)
plt.title("All controls", fontsize=18)


ax = fig.add_subplot(gs[1, 0])
ax = settings_plot(ax)

sns.barplot(
    data=etf_graph,
    x="highfee",
    y="spread_resid",
    palette="Blues",
    errorbar="se",
    capsize=0.1,
)
plt.xlabel("")
# plt.xlabel("ETF management expense ratio (MER)",fontsize=18)
plt.ylabel("Bid-ask spread (basis points)", fontsize=18)
ax.set_xticklabels(["Low MER", "High MER"], fontsize=18)
plt.title("All controls", fontsize=18)

ax = fig.add_subplot(gs[1, 1])
ax = settings_plot(ax)

sns.barplot(
    data=etf_graph,
    x="highfee",
    y="mktshare_resid",
    palette="Blues",
    errorbar="se",
    capsize=0.1,
)
plt.xlabel("")
# plt.xlabel("ETF management expense ratio (MER)",fontsize=18)
plt.ylabel("Market shares", fontsize=18)
ax.set_xticklabels(["Low MER", "High MER"], fontsize=18)
plt.title("All controls", fontsize=18)

ax = fig.add_subplot(gs[1, 2])
ax = settings_plot(ax)

sns.barplot(
    data=etf_graph,
    x="highfee",
    y="volume_resid",
    palette="Blues",
    errorbar="se",
    capsize=0.1,
)
plt.xlabel("")
# plt.xlabel("ETF management expense ratio (MER)",fontsize=18)
plt.ylabel("Trading volume (logs)", fontsize=18)
ax.set_xticklabels(["Low MER", "High MER"], fontsize=18)
plt.title("All controls", fontsize=18)

ax = fig.add_subplot(gs[1, 3])
ax = settings_plot(ax)

sns.barplot(
    data=etf_graph,
    x="highfee",
    y="turnover_resid",
    palette="Blues",
    errorbar="se",
    capsize=0.1,
)
plt.xlabel("")
# plt.xlabel("ETF management expense ratio (MER)",fontsize=18)
plt.ylabel("Turnover", fontsize=18)
ax.set_xticklabels(["Low MER", "High MER"], fontsize=18)
plt.title("No controls", fontsize=18)

plt.tight_layout(pad=2)
plt.savefig(path + "main_graph_RR.png", bbox_inches="tight")

# Get panel of quarterly differences
# -----------------------------------

panel_diff = etf_graph.pivot(columns="highfee")
# list of columns to get differences from
col_diffs = [
    "lend_byAUM_bps",
    "d_UIT",
    "aum",
    "log_aum",
    "cum_mktg_expense",
    "log_volume",
    "logret_q",
    "logret_q_lag",
    "marketing_fee_bps",
    "mer_bps",
    "mgr_duration",
    "mgr_duration_tii",
    "mgr_duration_tsi",
    "mkt_share",
    "perf_drag_bps",
    "ratio_tii",
    "ratio_tra",
    "spread_bps_crsp",
    "stock_tweets",
    "time_existence",
    "tr_error_bps",
    "turnover_frac",
]

for c in col_diffs:
    if c == "mkt_share":
        panel_diff[c + "_sum"] = panel_diff[(c, 1)] + panel_diff[(c, 0)]
        panel_diff[c + "_sum"] = np.where(
            panel_diff[c + "_sum"] == 0, 1, panel_diff[c + "_sum"]
        )
        panel_diff[c + "_diff"] = (
            2 * (panel_diff[(c, 1)] - panel_diff[(c, 0)]) / panel_diff[c + "_sum"]
        )

        # panel_diff[c+"_diff"]=panel_diff[(c,1)]-panel_diff[(c,0)]
    else:
        panel_diff[c + "_sum"] = panel_diff[(c, 1)] + panel_diff[(c, 0)]
        panel_diff[c + "_sum"] = np.where(
            panel_diff[c + "_sum"] == 0, 1, panel_diff[c + "_sum"]
        )
        panel_diff[c + "_diff"] = (
            2 * (panel_diff[(c, 1)] - panel_diff[(c, 0)]) / panel_diff[c + "_sum"]
        )
        # panel_diff[c+"_diff"]=(panel_diff[(c,1)]-panel_diff[(c,0)])


panel_diff = panel_diff[[c + "_diff" for c in col_diffs]]
panel_diff = panel_diff.reset_index()

panel_diff = panel_diff.merge(
    etf_panel[
        ["index_id", "quarter", "d_UIT", "mgr_duration_index", "ratio_tra_ix"]
    ].drop_duplicates(),
    on=["index_id", "quarter"],
    how="left",
)
panel_diff.to_csv("../data/etf_panel_differences_RR.csv")

#### Plot to see first mover advantage
controls_v2 = """EntityEffects + TimeEffects + other_expenses + fee_waivers + lend_byAUM_bps + stock_tweets +
                                  marketing_fee_bps + tr_error_bps + perf_drag_bps + creation_fee + ratio_tii 
                                  + same_benchmark + same_lead_mm"""
## Controls for spreads
highfee_resid = PanelOLS.from_formula(
    f"""highfee ~  {controls_v2}""", data=etf_graph
).fit()
etf_graph["hf_resid"] = highfee_resid.resids

etf_graph["Different benchmarks"] = 1 - etf_graph["same_benchmark"]


sizefigs_L = (18, 8)
fig = plt.figure(facecolor="white", figsize=sizefigs_L)
gs = gridspec.GridSpec(1, 3)

# ---------
ax = fig.add_subplot(gs[0, 0])
ax = settings_plot(ax)

sns.barplot(
    data=etf_graph,
    x="firstmover",
    y="highfee",
    palette="Blues",
    errorbar="se",
    capsize=0.1,
)
plt.xlabel("First mover", fontsize=18)
plt.ylabel("Proportion of high fee ETFs", fontsize=18)
ax.set_xticklabels(["No", "Yes"], fontsize=18)
plt.title("No controls", fontsize=18)


ax = fig.add_subplot(gs[0, 1])
ax = settings_plot(ax)

etf_graph["Different benchmarks"] = np.where(
    etf_graph["same_benchmark"] == 1, "No", "Yes"
)
sns.barplot(
    data=etf_graph,
    x="firstmover",
    y="hf_resid",
    hue="Different benchmarks",
    palette="Blues",
    errorbar="se",
    capsize=0.1,
)
plt.xlabel("First mover", fontsize=18)
plt.ylabel("Proportion of high fee ETFs", fontsize=18)
ax.set_xticklabels(["No", "Yes"], fontsize=18)

ax.legend(title="Different benchmarks", fontsize=18, title_fontsize=18, frameon=False)
plt.title("All controls", fontsize=18)


ax = fig.add_subplot(gs[0, 2])
ax = settings_plot(ax)

etf_graph["Major brand index"] = np.where(etf_graph["d_OwnIndex"] == 1, "No", "Yes")
sns.barplot(
    data=etf_graph,
    x="firstmover",
    y="hf_resid",
    hue="Major brand index",
    palette="Blues",
    errorbar="se",
    capsize=0.1,
)
plt.xlabel("First mover", fontsize=18)
plt.ylabel("Proportion of high fee ETFs", fontsize=18)
ax.set_xticklabels(["No", "Yes"], fontsize=18)

ax.legend(title="Major brand index", fontsize=18, title_fontsize=18, frameon=False)
plt.title("All controls", fontsize=18)
plt.tight_layout(pad=2)
plt.savefig(path + "first_mover.png", bbox_inches="tight")


list_funds = (
    etf_panel[
        ["index_id", "ticker", "inception", "primary_benchmark", "lead_market_maker"]
    ]
    .drop_duplicates(subset="ticker", keep="last")
    .sort_values(by="index_id")
    .reset_index(drop=True)
)
list_funds = list_funds.merge(
    etf_panel.groupby(["ticker"]).mean()["aum"].reset_index(), on="ticker"
)
