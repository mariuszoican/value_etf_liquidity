import wrds
from hydra import compose, initialize
from omegaconf import OmegaConf
import pandas as pd
import numpy as np
import datetime as dt
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib import cm, rcParams
from matplotlib import rc, font_manager
import matplotlib.patches as mpatches
import matplotlib.gridspec as gridspec

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

    re_download = False

    if re_download:
        conn = wrds.Connection(wrds_username=cfg.wrds_user)  # login to WRDS account

        print("Connection successful. Get 13F data for Thomson Reuters")

        panel = pd.read_csv(
            f"{cfg.raw_folder}/etf_panel_raw.csv",
            index_col=0,
            parse_dates=["inception"],
        )

        inception_dates = (
            panel.groupby(["ticker", "index_id"])["inception"].mean().reset_index()
        )
        inception_dates["entry_order"] = inception_dates.groupby("index_id")[
            "inception"
        ].rank()

        list_tickers = panel.ticker.drop_duplicates().tolist()

        # get ETFG data
        data_entry = conn.raw_sql(
            f""" SELECT as_of_date, composite_ticker, aum, management_fee, other_expenses, fee_waivers, bid_ask_spread, creation_fee FROM etfg_industry.industry
                            WHERE composite_ticker IN {tuple(list_tickers)} """,
            date_cols=["as_of_date", "inception"],
        )
        data_entry = data_entry.rename(columns={"composite_ticker": "ticker"})

        data_entry = data_entry.merge(
            inception_dates,
            on=["ticker"],
            how="left",
        )

        data_entry.to_csv(f"{cfg.data_folder}/entry_data.csv", index=False)
    else:
        data_entry = pd.read_csv(
            f"{cfg.data_folder}/entry_data.csv",
            parse_dates=["as_of_date", "inception"],
        )

    data_entry["quarter"] = data_entry["as_of_date"].apply(
        lambda x: x.year * 10 + x.quarter
    )

    list_ETF_tickers = data_entry.ticker.drop_duplicates().tolist()
    etf_panel = pd.read_csv(f"{cfg.raw_folder}/etf_panel_raw.csv", index_col=0)
    manager_data = pd.read_csv(
        f"{cfg.raw_folder}/iiclass.csv", index_col=0
    ).reset_index()
    manager_data["tax_extend"] = manager_data.groupby("permakey", group_keys=False)[
        "tax_extend"
    ].apply(lambda x: x.fillna(method="ffill"))

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

    # panel = pd.read_csv(f"{cfg.data_folder}/etf_clientele_measures.csv.gz", index_col=0)

    spreads = pd.read_csv(
        f"{cfg.data_folder}/etf_spread_measures.csv", index_col=0, parse_dates=["date"]
    )
    spreads = spreads.rename(columns={"date": "as_of_date"})
    spreads["as_of_date"] = spreads["as_of_date"].dt.date

    data_entry = data_entry.merge(
        etf_measures[
            [
                "ticker",
                "quarter",
                "ratio_tra",
                "ratio_tii",
                "mgr_duration",
                "mgr_duration_tii",
                "mgr_duration_tsi",
            ]
        ],
        on=["ticker", "quarter"],
        how="left",
    )

    data_entry = data_entry.merge(transient_ix, on=["index_id", "quarter"], how="left")

    # get window around events
    entrant_inception = (
        data_entry[data_entry.entry_order == 2]
        .groupby("index_id")["inception"]
        .mean()
        .reset_index()
    )
    entrant_inception = entrant_inception.rename(columns={"inception": "entry_date"})
    data_entry = data_entry.merge(entrant_inception, on="index_id", how="left")
    data_entry["management_fee"] = (
        data_entry.groupby("ticker")["management_fee"].ffill().bfill()
    )

    data_entry["as_of_date"] = data_entry["as_of_date"].dt.date
    data_entry["entry_date"] = data_entry["entry_date"].dt.date

    data_entry = data_entry[data_entry.entry_date >= dt.date(2016, 1, 1)]

    data_entry["distance_from_entry"] = data_entry.apply(
        lambda row: np.busday_count(row["entry_date"], row["as_of_date"]), axis=1
    )
    data_entry["abs_distance_from_entry"] = data_entry["distance_from_entry"].abs()

    data_entry["aum_index"] = data_entry.groupby(["as_of_date", "index_id"])[
        "aum"
    ].transform(sum)
    data_entry["mkt_share"] = data_entry["aum"] / data_entry["aum_index"]

    window_entry = data_entry[data_entry["abs_distance_from_entry"] <= cfg.entry_window]
    window_entry = window_entry.merge(
        spreads[["as_of_date", "ticker", "quotedspread_percent_tw"]],
        on=["as_of_date", "ticker"],
        how="left",
    )

    mer_entry = window_entry[
        (window_entry.entry_order == 1)
        & (window_entry.as_of_date == window_entry.entry_date)
    ][
        [
            "ticker",
            "management_fee",
            "ratio_tra",
            "ratio_tra_ix",
            "ratio_tii",
            "mgr_duration_tii",
            "mgr_duration_tsi",
            "quotedspread_percent_tw",
            "aum",
            "aum_index",
        ]
    ].reset_index(
        drop=True
    )
    mer_entry = mer_entry.rename(
        columns={
            "management_fee": "leader_mer_entry",
            "aum": "leader_aum_entry",
            "ratio_tra": "leader_tra_entry",
            "ratio_tra_ix": "leader_tra_ix_entry",
            "ratio_tii": "leader_tii_entry",
            "mgr_duration_tii": "leader_mgr_duration_tii_entry",
            "mgr_duration_tsi": "leader_mgr_duration_tsi_entry",
            "quotedspread_percent_tw": "leader_quotedspread_percent_tw_entry",
        }
    )

    window_entry = window_entry.merge(mer_entry, on="ticker", how="left")

    window_entry["mer_ratio"] = np.round(
        window_entry["management_fee"] / window_entry["leader_mer_entry"], 2
    )
    window_entry["aum_ratio"] = np.round(
        window_entry["aum"] / window_entry["leader_aum_entry"], 2
    )
    window_entry["tra_ratio"] = np.round(
        window_entry["ratio_tra"] / window_entry["leader_tra_entry"], 2
    )

    window_entry["tra_ix_ratio"] = np.round(
        window_entry["ratio_tra_ix"] / window_entry["leader_tra_ix_entry"], 2
    )
    window_entry["tii_ratio"] = np.round(
        window_entry["ratio_tii"] / window_entry["leader_tii_entry"], 2
    )
    window_entry["mgr_duration_tii_ratio"] = np.round(
        window_entry["mgr_duration_tii"]
        / window_entry["leader_mgr_duration_tii_entry"],
        2,
    )
    window_entry["mgr_duration_tsi_ratio"] = np.round(
        window_entry["mgr_duration_tsi"]
        / window_entry["leader_mgr_duration_tsi_entry"],
        2,
    )
    window_entry["spread_ratio"] = np.round(
        window_entry["quotedspread_percent_tw"]
        / window_entry["leader_quotedspread_percent_tw_entry"],
        2,
    )
    window_entry["d_post"] = 1 * (window_entry["distance_from_entry"] > 0)

    size_window = (
        window_entry.groupby("ticker")["distance_from_entry"]
        .agg({"min", "max"})
        .reset_index()
    )
    window_entry = window_entry.merge(size_window, on="ticker", how="left")

    window_entry = window_entry[
        (window_entry["max"] >= 252) & (window_entry["min"] <= -252)
    ]

    change = (
        window_entry[window_entry.entry_order == 1]
        .groupby(["ticker", "d_post"])["management_fee"]
        .mean()
        .reset_index()
    )
    change = change.pivot(index="ticker", columns="d_post")
    change.columns = ["fee_0", "fee_1"]
    change["fee_diff"] = change["fee_1"] - change["fee_0"]

    pivot_mer = (
        window_entry.drop_duplicates(subset=["ticker", "distance_from_entry"])
        .pivot(
            index=["distance_from_entry"],
            columns=["ticker"],
            values=[
                "management_fee",
                "mer_ratio",
                "ratio_tra",
                "tra_ratio",
                "ratio_tra_ix",
                "tra_ix_ratio",
                "ratio_tii",
                "aum_ratio",
                "tii_ratio",
                "quotedspread_percent_tw",
                "spread_ratio",
                "mgr_duration_tii",
                "mgr_duration_tsi",
                "mgr_duration",
                "mgr_duration_tii_ratio",
                "mgr_duration_tsi_ratio",
                "entry_order",
                "d_post",
                "mkt_share",
            ],
        )
        .fillna(method="ffill")
        .fillna(method="bfill")
        .stack()
        .reset_index()
    )

    group_tickers = (
        pivot_mer[pivot_mer.d_post == 0]
        .groupby(["ticker"])["mer_ratio"]
        .mean()
        .reset_index()
    )
    group_tickers = group_tickers.rename(columns={"mer_ratio": "before_ratio"})
    group_tickers["sign_change"] = np.where(
        group_tickers["before_ratio"] > 1,
        1,
        np.where(group_tickers["before_ratio"] < 1, -1, 0),
    )
    pivot_mer = pivot_mer.merge(group_tickers, on="ticker")

    pre_transient = (
        pivot_mer[pivot_mer.d_post == 0]
        .groupby("ticker")[["ratio_tra", "ratio_tii", "quotedspread_percent_tw"]]
        .mean()
        .reset_index()
    )
    pre_transient = pre_transient.rename(
        columns={
            "ratio_tra": "pre_tra",
            "ratio_tii": "pre_tii",
            "quotedspread_percent_tw": "pre_spread",
        }
    )
    pivot_mer = pivot_mer.merge(pre_transient, on="ticker", how="left")
    pivot_mer["ratio_tra_above"] = 1 * (
        pivot_mer["pre_tra"]
        >= pre_transient.set_index("ticker")["pre_tra"].mean().mean()
    )
    pivot_mer["ratio_tii_above"] = 1 * (
        pivot_mer["pre_tii"]
        >= pre_transient.set_index("ticker")["pre_tii"].mean().mean()
    )
    pivot_mer["spread_above"] = 1 * (
        pivot_mer["pre_spread"]
        >= pre_transient.set_index("ticker")["pre_spread"].mean().mean()
    )
    sizefigs_L = (22, 10)
    fig = plt.figure(facecolor="white", figsize=sizefigs_L)
    gs = gridspec.GridSpec(2, 2)

    # ---------
    ax = fig.add_subplot(gs[0, :])
    ax = settings_plot(ax)

    sns.lineplot(
        data=pivot_mer[(pivot_mer.entry_order == 1)],
        x="distance_from_entry",
        y="mer_ratio",
        errorbar=("ci", 95),
        c="b",
        lw=2,
    )

    plt.axvline(x=0, c="k", ls="--", lw=2)
    plt.text(2, 1.05, "Follower entry", fontsize=20, ha="left", va="bottom")

    plt.xlabel("Days from entry", fontsize=20)
    plt.ylabel("Normalized fee", fontsize=20)
    plt.legend(loc="best", fontsize=20, frameon=False)
    plt.title("Panel (a): Aggregate fee dynamics around entry", fontsize=20)

    ax = fig.add_subplot(gs[1, 0])
    ax = settings_plot(ax)

    sns.lineplot(
        data=pivot_mer[
            (pivot_mer.entry_order == 1) & (pivot_mer.sign_change != 0)
        ].dropna(subset="mer_ratio"),
        x="distance_from_entry",
        y="mer_ratio",
        errorbar=None,
        hue="sign_change",
        palette=["b", "r"],
        lw=2,
    )

    plt.xlabel("Days from entry", fontsize=20)
    plt.ylabel("Normalized fee", fontsize=20)
    ax.legend(
        title="Incumbent fee",
        fontsize=16,
        title_fontsize=18,
        frameon=False,
        labels=["Higher after entry", "Lower after entry"],
    )

    plt.axvline(x=0, c="k", ls="--", lw=2)
    plt.text(2, 1.04, "Follower entry", fontsize=20, ha="left", va="bottom")
    plt.title("Panel (b): Heterogeneity in fee dynamics around entry", fontsize=20)

    ax = fig.add_subplot(gs[1, 1])
    ax = settings_plot(ax)

    sns.lineplot(
        data=pivot_mer[
            (pivot_mer.entry_order == 1) & (pivot_mer.sign_change.isin([1, -1]))
        ],
        x="distance_from_entry",
        y="aum_ratio",
        errorbar=None,
        hue="sign_change",
        palette=["b", "r"],
        lw=2,
    )

    plt.axvline(x=0, c="k", ls="--", lw=2)
    plt.text(2, 0.85, "Follower entry", fontsize=20, ha="left", va="bottom")

    plt.xlabel("Days from entry", fontsize=20)
    plt.ylabel("Normalized AUM", fontsize=20)
    ax.legend(
        title="Incumbent fee",
        fontsize=16,
        title_fontsize=18,
        frameon=False,
        labels=["Higher after entry", "Lower after entry"],
    )
    plt.title("Panel (c): Heterogeneity in AUM dynamics around entry", fontsize=20)
    plt.tight_layout(pad=2)
    plt.savefig("../output/entry_dynamics.png", bbox_inches="tight")
