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

    data_entry["distance_from_entry"] = data_entry.apply(
        lambda row: np.busday_count(row["entry_date"], row["as_of_date"]), axis=1
    )
    data_entry["abs_distance_from_entry"] = data_entry["distance_from_entry"].abs()

    window_entry = data_entry[data_entry["abs_distance_from_entry"] <= cfg.entry_window]

    mer_entry = window_entry[
        (window_entry.entry_order == 1)
        & (window_entry.as_of_date == window_entry.entry_date)
    ][["ticker", "management_fee"]].reset_index(drop=True)
    mer_entry = mer_entry.rename(columns={"management_fee": "leader_mer_entry"})

    window_entry = window_entry.merge(mer_entry, on="ticker", how="left")

    window_entry["mer_ratio"] = np.round(
        window_entry["management_fee"] / window_entry["leader_mer_entry"], 2
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

    window_entry["yearmonth"] = window_entry["as_of_date"].apply(
        lambda x: dt.datetime(x.year, x.month, 15)
    )
    window_entry["entry_month"] = window_entry["entry_date"].apply(
        lambda x: dt.datetime(x.year, x.month, 15)
    )

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
            values=["management_fee", "mer_ratio", "entry_order", "d_post"],
        )
        .fillna(method="ffill")
        .fillna(method="bfill")
        .stack()
        .reset_index()
    )

    pivot_mer_2 = (
        window_entry.drop_duplicates(subset=["ticker", "distance_from_entry"])
        .pivot(
            index=["distance_from_entry"],
            columns=["ticker"],
            values=["management_fee"],
        )
        .fillna(method="ffill")
        .fillna(method="bfill")
    )

    sns.lineplot(
        data=pivot_mer[(pivot_mer.entry_order == 1)],
        x="distance_from_entry",
        y="mer_ratio",
        errorbar=("se", 2),
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

    sns.lineplot(
        data=pivot_mer[(pivot_mer.entry_order == 1) & (pivot_mer.sign_change != 0)],
        x="distance_from_entry",
        y="mer_ratio",
        errorbar=None,
        hue="sign_change",
    )
