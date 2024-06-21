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

    # Loading panels
    # --------------------------
    manager_data = pd.read_csv(
        f"{cfg.raw_folder}/iiclass.csv", index_col=0
    ).reset_index()
    manager_data["tax_extend"] = manager_data.groupby("permakey", group_keys=False)[
        "tax_extend"
    ].apply(lambda x: x.fillna(method="ffill"))
    manager_data = manager_data[manager_data.year >= 2016]  # keep data in our sample
    probit_file = pd.read_csv(f"{cfg.raw_folder}/probit_raw.csv", index_col=0)

    # Load ETF panel and apply Broman-Shum (2018) filters
    # ----------------------------------------------------
    etf_panel = pd.read_csv(f"{cfg.raw_folder}/etf_panel_raw.csv", index_col=0)

    # compute profit
    etf_panel["log_profit"] = (
        (etf_panel["mer_bps"] / 10**4) * (etf_panel["aum"])
    ).map(np.log)

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

    etf_panel = (
        etf_panel.groupby(["index_id", "quarter"])
        .apply(lambda x: rank_group(x, 2, "aum", "top2aum"))
        .reset_index(drop=True)
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
        etf_panel["rank_spread"] == 2,
        1,
        np.where(etf_panel["rank_spread"] == 1, 0, np.nan),
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

    # add more data from WRDS ETF Global
    extra_data = pd.read_csv(
        f"{cfg.data_folder}/dummies_etfg.csv.gz", keep_default_na=False, na_values=[""]
    )
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
                "management_fee",
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
    d13furg = pd.read_csv(f"{cfg.data_folder}/duration_13F.csv.gz", index_col=0)
    d13furg["year"] = d13furg["quarter"].apply(lambda x: int(x / 10))
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

    cols_mgr = ["mgrno", "year", "horizon_perma", "type", "tax_extend"]
    d13furg = d13furg.merge(manager_data[cols_mgr], on=["mgrno", "year"], how="left")
    # Follow Broman-Shum (2018) and keep only quasi-indexers and transient investors
    d13furg = d13furg[d13furg.horizon_perma.isin(["QIX", "TRA"])]

    # FILTER: drop rows where institutional ownership > shares outstanding
    d13furg["inst_shares"] = d13furg.groupby(["ticker", "quarter"])["shares"].transform(
        sum
    )
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
            lambda x: (x["mgr_duration"] * x["dollar_pos"]).sum()
            / x["dollar_pos"].sum()
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
            lambda x: (x["time_since_first_inv"] * x["shares"]).sum()
            / x["shares"].sum()
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

    # etf_measures.to_csv(
    #     f"{cfg.data_folder}/etf_clientele_measures.csv.gz", compression="gzip"
    # )

    # merge into main ETF panel
    etf_panel = etf_panel.merge(etf_measures, on=["ticker", "quarter"], how="left")
    etf_panel = etf_panel.merge(
        etf_duration_index, on=["index_id", "quarter"], how="left"
    )
    etf_panel = etf_panel.merge(transient_ix, on=["index_id", "quarter"], how="left")

    # load StockTwits data
    stock_twits = pd.read_csv(f"{cfg.raw_folder}/stocktwits_etf.csv", index_col=0)
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
    stock_twits_q["stock_tweets"] = scaler.fit_transform(
        stock_twits_q[["stock_tweets"]]
    )
    # stock_twits_q['stock_tweets']=winsorize(stock_twits_q['stock_tweets'], limits=(0,0.01))

    etf_panel["aum_index"] = etf_panel.groupby(["index_id", "quarter"])[
        "aum"
    ].transform(sum)
    etf_panel["log_aum_index"] = etf_panel["aum_index"].map(np.log)
    etf_panel["log_aum"] = etf_panel["aum"].map(np.log)
    etf_panel = etf_panel.merge(stock_twits_q, on=["ticker", "quarter"], how="left")
    etf_panel["stock_tweets"] = etf_panel["stock_tweets"].fillna(0)
    etf_panel["stock_tweets_raw"] = etf_panel["stock_tweets_raw"].fillna(0)

    etf_panel["qduration"] = pd.qcut(etf_panel["mgr_duration"], q=5, labels=False) + 1

    etf_graph = (
        etf_panel[(etf_panel.etf_per_index == 2)].dropna(subset=["highfee"]).copy()
    )

    count_benchmarks = (
        etf_graph.groupby(["index_id", "quarter"])[
            ["primary_benchmark", "lead_market_maker"]
        ]
        .nunique()
        .reset_index()
    )
    count_benchmarks = count_benchmarks.rename(
        columns={
            "primary_benchmark": "same_benchmark",
            "lead_market_maker": "same_lead_mm",
        }
    )
    count_benchmarks["same_benchmark"] = 2 - count_benchmarks["same_benchmark"]
    count_benchmarks["same_lead_mm"] = 2 - count_benchmarks["same_lead_mm"]

    etf_graph = etf_graph.merge(
        count_benchmarks, on=["index_id", "quarter"], how="left"
    )

    ## Add effective and realized spread measures
    spreads = pd.read_csv(f"{cfg.data_folder}/etf_spread_measures.csv", index_col=0)
    spreads["date"] = spreads["date"].apply(
        lambda x: dt.datetime.strptime(x, "%Y-%m-%d")
    )
    spreads["quarter"] = spreads["date"].apply(lambda x: 10 * x.year + x.quarter)
    spreads_q = spreads.groupby(["ticker", "quarter"]).mean().reset_index()

    # merge with spread values
    etf_graph = etf_graph.merge(
        spreads_q[
            [
                "ticker",
                "quarter",
                "effectivespread_dollar_ave",
                "effectivespread_percent_ave",
                "effectivespread_dollar_dw",
                "effectivespread_dollar_sw",
                "effectivespread_percent_dw",
                "effectivespread_percent_sw",
                "dollarrealizedspread_lr_ave",
                "percentrealizedspread_lr_ave",
                "dollarrealizedspread_lr_sw",
                "dollarrealizedspread_lr_dw",
                "percentrealizedspread_lr_sw",
                "percentrealizedspread_lr_dw",
                "dollarpriceimpact_lr_ave",
                "percentpriceimpact_lr_ave",
                "dollarpriceimpact_lr_sw",
                "dollarpriceimpact_lr_dw",
                "percentpriceimpact_lr_sw",
                "percentpriceimpact_lr_dw",
                "quotedspread_dollar_tw",
                "quotedspread_percent_tw",
            ]
        ],
        on=["ticker", "quarter"],
        how="left",
    )

    etf_graph_for_cs = etf_graph.copy()
    etf_graph_for_cs["volume"] = etf_graph_for_cs["log_volume"].map(np.exp)
    etf_graph_for_cs["aum_index"] = etf_graph_for_cs["log_aum_index"].map(np.exp)
    etf_graph_for_cs["net_expense_mer"] = (
        etf_graph_for_cs["other_expenses"]
        - etf_graph_for_cs["marketing_fee_bps"] / 100
        + etf_graph_for_cs["fee_waivers"]
    )
    cs_panel = (
        etf_graph_for_cs.groupby(["ticker", "index_id"])[
            [
                "lend_byAUM_bps",
                "mer_bps",
                "spread_bps_crsp",
                "volume",
                "tr_error_bps",
                "perf_drag_bps",
                "turnover_frac",
                "d_UIT",
                "mkt_share",
                "marketing_fee_bps",
                "aum",
                "aum_index",
                "highfee",
                "other_expenses",
                "fee_waivers",
                "net_expense_mer",
                "mgr_duration",
                "mgr_duration_tii",
                "mgr_duration_tsi",
                "ratio_tra",
                "ratio_tii",
                "stock_tweets",
                "effectivespread_dollar_ave",
                "effectivespread_percent_ave",
                "effectivespread_dollar_dw",
                "effectivespread_dollar_sw",
                "effectivespread_percent_dw",
                "effectivespread_percent_sw",
                "dollarrealizedspread_lr_ave",
                "percentrealizedspread_lr_ave",
                "dollarrealizedspread_lr_sw",
                "dollarrealizedspread_lr_dw",
                "percentrealizedspread_lr_sw",
                "percentrealizedspread_lr_dw",
                "dollarpriceimpact_lr_ave",
                "percentpriceimpact_lr_ave",
                "dollarpriceimpact_lr_sw",
                "dollarpriceimpact_lr_dw",
                "percentpriceimpact_lr_sw",
                "percentpriceimpact_lr_dw",
                "quotedspread_dollar_tw",
                "quotedspread_percent_tw",
            ]
        ]
        .mean()
        .reset_index()
    )
    cs_panel["log_volume"] = cs_panel["volume"].map(np.log)
    cs_panel["log_aum_index"] = cs_panel["aum_index"].map(np.log)
    cs_panel.to_csv(f"{cfg.data_folder}/cs_panel.csv")

    etf_graph["mer_avg_ix"] = etf_graph.groupby(["index_id", "quarter"])[
        "mer_bps"
    ].transform("mean")

    crsp_data = pd.read_csv("../data/data_crsp.csv.gz")
    etf_graph = etf_graph.merge(
        crsp_data[["ticker", "quarter", "prc"]].drop_duplicates(
            subset=["ticker", "quarter"], keep="last"
        ),
        on=["ticker", "quarter"],
        how="left",
    )

    etf_graph.to_csv(f"{cfg.data_folder}/etf_panel_processed.csv")

    from linearmodels.panel import PanelOLS

    etf_graph = etf_graph.set_index(["index_id", "quarter"])
    etf_graph["net_expense"] = (
        etf_graph["other_expenses"]
        - etf_graph["marketing_fee_bps"] / 100
        + etf_graph["fee_waivers"]
    )
    etf_graph = etf_graph.dropna()
    inv_dur_reg = PanelOLS.from_formula(
        """mgr_duration ~  EntityEffects + TimeEffects + stock_tweets + log_aum_index + lend_byAUM_bps + 
                                    marketing_fee_bps + net_expense + tr_error_bps + perf_drag_bps + d_UIT + time_existence + time_since_first""",
        data=etf_graph,
    ).fit()
    etf_graph["dur_resid"] = inv_dur_reg.resids

    rat_tra_reg = PanelOLS.from_formula(
        """ratio_tra ~  EntityEffects + TimeEffects + stock_tweets + log_aum_index + lend_byAUM_bps + 
                                    marketing_fee_bps + net_expense + tr_error_bps + perf_drag_bps + d_UIT + time_since_first""",
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
    ax = fig.add_subplot(gs[0, 0])
    ax = settings_plot(ax)

    sns.barplot(
        data=etf_graph,
        y="highfee",
        x="ratio_tra",
        capsize=0.1,
        errorbar=("ci", 95),
        palette="Blues",
        orient="h",
    )
    plt.ylabel("ETF management fee", fontsize=18)
    plt.xlabel("AUM share of transient investors", fontsize=18)
    ax.set_yticklabels(["Low fee", "High fee"], fontsize=18)
    plt.title("Panel (a): No controls", fontsize=18)

    ax = fig.add_subplot(gs[0, 1])
    ax = settings_plot(ax)

    sns.barplot(
        data=etf_graph,
        y="highfee",
        x="tra_resid",
        capsize=0.1,
        errorbar=("ci", 95),
        palette="Blues",
        orient="h",
    )
    plt.ylabel("ETF management fee", fontsize=18)
    plt.xlabel("Residual AUM share of transient investors", fontsize=18)
    ax.set_yticklabels(["Low fee", "High fee"], fontsize=18)
    plt.title("Panel (b): All controls", fontsize=18)

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
        aum_quarter_tax["highfee"] == 1, "High fee", "Low fee"
    )
    aum_quarter_tra = (
        d13furg_micro.groupby(["quarter", "horizon_perma", "highfee"])
        .sum()["dollar_pos"]
        .reset_index()
    )
    aum_quarter_tra["dollar_pos"] = aum_quarter_tra["dollar_pos"] / 10**9
    aum_quarter_tra["highfee"] = np.where(
        aum_quarter_tra["highfee"] == 1, "High fee", "Low fee"
    )

    aum_quarter_tax["dollar_pos_pct"] = aum_quarter_tax[
        "dollar_pos"
    ] / aum_quarter_tax.groupby(["quarter", "tax_extend"])["dollar_pos"].transform(
        "sum"
    )
    aum_quarter_tra["dollar_pos_pct"] = aum_quarter_tra[
        "dollar_pos"
    ] / aum_quarter_tra.groupby(["quarter", "horizon_perma"])["dollar_pos"].transform(
        "sum"
    )

    sizefigs_L = (16, 16)
    fig = plt.figure(facecolor="white", figsize=sizefigs_L)
    gs = gridspec.GridSpec(3, 2)

    # ---------
    ax = fig.add_subplot(gs[0, 0])
    ax = settings_plot(ax)
    sns.barplot(
        data=aum_quarter_tax,
        x="tax_extend",
        y="dollar_pos",
        hue="highfee",
        errorbar=("ci", 95),
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
        errorbar=("ci", 95),
        capsize=0.05,
        palette="Blues",
    )
    plt.xlabel("Investor horizon", fontsize=18)
    plt.ylabel(r"Investor holdings (US\$bn)", fontsize=18)
    ax.legend(title="ETF management fee", fontsize=16, title_fontsize=18, frameon=False)

    ax.set_xticklabels(["Quasi-indexers", "Transient investor"], fontsize=18)
    plt.title("Panel (b): Holdings by investor horizon", fontsize=18)

    # ---------
    ax = fig.add_subplot(gs[1, 0])
    ax = settings_plot(ax)
    sns.barplot(
        data=aum_quarter_tax,
        x="tax_extend",
        y="dollar_pos_pct",
        hue="highfee",
        errorbar=("ci", 95),
        capsize=0.05,
        palette="Blues",
    )
    plt.xlabel("Tax sensitivity", fontsize=18)
    plt.ylim(0, 1.25)
    plt.ylabel(r"Investor holdings (fraction)", fontsize=18)
    ax.legend(
        title="ETF management fee",
        fontsize=16,
        title_fontsize=18,
        frameon=False,
        loc="upper left",
    )

    ax.set_xticklabels(["Tax insensitive", "Tax sensitive"], fontsize=18)
    plt.title("Panel (c): Holdings by tax sensitivity", fontsize=18)

    ax = fig.add_subplot(gs[1, 1])
    ax = settings_plot(ax)
    sns.barplot(
        data=aum_quarter_tra,
        x="horizon_perma",
        y="dollar_pos_pct",
        hue="highfee",
        errorbar=("ci", 95),
        capsize=0.05,
        palette="Blues",
    )
    plt.xlabel("Investor horizon", fontsize=18)
    plt.ylabel(r"Investor holdings (fraction)", fontsize=18)
    plt.ylim(0, 1.25)
    ax.legend(
        title="ETF management fee",
        fontsize=16,
        title_fontsize=18,
        frameon=False,
        loc="upper right",
    )

    ax.set_xticklabels(["Quasi-indexers", "Transient investor"], fontsize=18)
    plt.title("Panel (d): Holdings by investor horizon", fontsize=18)

    ax = fig.add_subplot(gs[2, 0])
    ax = settings_plot(ax)
    sns.kdeplot(data=d13furg, x="mgr_duration", hue="horizon_perma", common_norm=False)
    plt.xlabel("Investor holding duration", fontsize=18)
    plt.ylabel("Density", fontsize=18)
    ax.legend(
        title="Investor horizon",
        fontsize=16,
        title_fontsize=18,
        frameon=False,
        labels=["Quasi-indexers", "Transient"],
    )
    plt.title("Panel (e): Holding durations by investor horizon", fontsize=18)

    ax = fig.add_subplot(gs[2, 1])
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
    plt.title("Panel (f): Holding durations by tax status", fontsize=18)

    plt.tight_layout(pad=4)
    plt.savefig(path + "micro_sumstats.png", bbox_inches="tight")

    sizefigs_L = (12, 3)
    fig = plt.figure(facecolor="white", figsize=sizefigs_L)
    gs = gridspec.GridSpec(1, 1)

    # ---------
    ax = fig.add_subplot(gs[0, 0])
    ax = settings_plot(ax)
    sns.histplot(
        (1 / d13furg["mgr_duration"]), stat="percent", bins=20, palette="Blues"
    )
    plt.xlabel("Inverse of investor holding duration (quarters)", fontsize=18)
    plt.ylabel(r"% of the sample", fontsize=18)
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
    mkt_reg = PanelOLS.from_formula(
        f"""mkt_share ~  {controls}""", data=etf_graph
    ).fit()
    etf_graph["mktshare_resid"] = mkt_reg.resids

    ## Controls for log volume
    vol_reg = PanelOLS.from_formula(
        f"""log_volume ~  {controls}""", data=etf_graph
    ).fit()
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
        errorbar=("ci", 95),
        capsize=0.1,
    )
    plt.xlabel("")
    # plt.xlabel("ETF management expense ratio (MER)",fontsize=18)
    plt.ylabel("Bid-ask spread (basis points)", fontsize=18)
    ax.set_xticklabels(["Low fee", "High fee"], fontsize=18)
    plt.title("No controls", fontsize=18)

    ax = fig.add_subplot(gs[0, 1])
    ax = settings_plot(ax)

    sns.barplot(
        data=etf_graph,
        x="highfee",
        y="mkt_share",
        palette="Blues",
        errorbar=("ci", 95),
        capsize=0.1,
    )
    plt.xlabel("")
    # plt.xlabel("ETF management expense ratio (MER)",fontsize=18)
    plt.ylabel("Market shares", fontsize=18)
    ax.set_xticklabels(["Low fee", "High fee"], fontsize=18)
    plt.title("No controls", fontsize=18)

    ax = fig.add_subplot(gs[0, 2])
    ax = settings_plot(ax)

    sns.barplot(
        data=etf_graph,
        x="highfee",
        y="log_volume",
        palette="Blues",
        errorbar=("ci", 95),
        capsize=0.1,
    )
    plt.xlabel("")
    # plt.xlabel("ETF management expense ratio (MER)",fontsize=18)
    plt.ylabel("Trading volume (logs)", fontsize=18)
    ax.set_xticklabels(["Low fee", "High fee"], fontsize=18)
    plt.title("No controls", fontsize=18)

    ax = fig.add_subplot(gs[0, 3])
    ax = settings_plot(ax)

    sns.barplot(
        data=etf_graph,
        x="highfee",
        y="turnover_frac",
        palette="Blues",
        errorbar=("ci", 95),
        capsize=0.1,
    )
    plt.xlabel("")
    # plt.xlabel("ETF management expense ratio (MER)",fontsize=18)
    plt.ylabel("Turnover", fontsize=18)
    ax.set_xticklabels(["Low fee", "High fee"], fontsize=18)
    plt.title("All controls", fontsize=18)

    ax = fig.add_subplot(gs[1, 0])
    ax = settings_plot(ax)

    sns.barplot(
        data=etf_graph,
        x="highfee",
        y="spread_resid",
        palette="Blues",
        errorbar=("ci", 95),
        capsize=0.1,
    )
    plt.xlabel("")
    # plt.xlabel("ETF management expense ratio (MER)",fontsize=18)
    plt.ylabel("Bid-ask spread (basis points)", fontsize=18)
    ax.set_xticklabels(["Low fee", "High fee"], fontsize=18)
    plt.title("All controls", fontsize=18)

    ax = fig.add_subplot(gs[1, 1])
    ax = settings_plot(ax)

    sns.barplot(
        data=etf_graph,
        x="highfee",
        y="mktshare_resid",
        palette="Blues",
        errorbar=("ci", 95),
        capsize=0.1,
    )
    plt.xlabel("")
    # plt.xlabel("ETF management expense ratio (MER)",fontsize=18)
    plt.ylabel("Market shares", fontsize=18)
    ax.set_xticklabels(["Low fee", "High fee"], fontsize=18)
    plt.title("All controls", fontsize=18)

    ax = fig.add_subplot(gs[1, 2])
    ax = settings_plot(ax)

    sns.barplot(
        data=etf_graph,
        x="highfee",
        y="volume_resid",
        palette="Blues",
        errorbar=("ci", 95),
        capsize=0.1,
    )
    plt.xlabel("")
    # plt.xlabel("ETF management expense ratio (MER)",fontsize=18)
    plt.ylabel("Trading volume (logs)", fontsize=18)
    ax.set_xticklabels(["Low fee", "High fee"], fontsize=18)
    plt.title("All controls", fontsize=18)

    ax = fig.add_subplot(gs[1, 3])
    ax = settings_plot(ax)

    sns.barplot(
        data=etf_graph,
        x="highfee",
        y="turnover_resid",
        palette="Blues",
        errorbar=("ci", 95),
        capsize=0.1,
    )
    plt.xlabel("")
    # plt.xlabel("ETF management expense ratio (MER)",fontsize=18)
    plt.ylabel("Turnover", fontsize=18)
    ax.set_xticklabels(["Low fee", "High fee"], fontsize=18)
    plt.title("No controls", fontsize=18)

    plt.tight_layout(pad=2)
    plt.savefig(path + "main_graph_RR.png", bbox_inches="tight")

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
        errorbar=("ci", 95),
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
        errorbar=("ci", 95),
        capsize=0.1,
    )
    plt.xlabel("First mover", fontsize=18)
    plt.ylabel("Proportion of high fee ETFs", fontsize=18)
    ax.set_xticklabels(["No", "Yes"], fontsize=18)

    ax.legend(
        title="Different benchmarks", fontsize=18, title_fontsize=18, frameon=False
    )
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
        errorbar=("ci", 95),
        capsize=0.1,
    )
    plt.xlabel("First mover", fontsize=18)
    plt.ylabel("Proportion of high fee ETFs", fontsize=18)
    ax.set_xticklabels(["No", "Yes"], fontsize=18)

    ax.legend(title="Major brand index", fontsize=18, title_fontsize=18, frameon=False)
    plt.title("All controls", fontsize=18)
    plt.tight_layout(pad=2)
    plt.savefig(path + "first_mover.png", bbox_inches="tight")
