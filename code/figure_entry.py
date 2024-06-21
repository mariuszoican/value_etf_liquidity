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

    re_download = True

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

    data_entry["quarter"] = data_entry["as_of_date"].dt.to_period("Q")

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

    leader_entry = window_entry[
        (window_entry.entry_order == 1)
        & (window_entry.as_of_date == window_entry.entry_date)
    ][
        [
            "ticker",
            "management_fee",
            "aum",
            "aum_index",
        ]
    ].reset_index(
        drop=True
    )

    leader_entry = leader_entry.rename(
        columns={
            "management_fee": "leader_mer_entry",
            "aum": "leader_aum_entry",
            "aum_index": "aum_index_entry",
        }
    )

    follower_entry = window_entry[
        (window_entry.entry_order == 2)
        & (window_entry.as_of_date == window_entry.entry_date + dt.timedelta(days=1))
    ][
        [
            "ticker",
            "management_fee",
            "aum",
        ]
    ].reset_index(
        drop=True
    )

    follower_entry = follower_entry.rename(
        columns={
            "management_fee": "follower_mer_entry",
            "aum": "follower_aum_entry",
        }
    )

    window_entry = window_entry.merge(leader_entry, on="ticker", how="left")
    window_entry = window_entry.merge(follower_entry, on="ticker", how="left")

    window_entry["mer_ratio"] = np.round(
        window_entry["management_fee"]
        / np.where(
            window_entry["entry_order"] == 1,
            window_entry["leader_mer_entry"],
            window_entry["follower_mer_entry"],
        ),
        2,
    )
    window_entry["aum_ratio"] = np.round(
        window_entry["aum"]
        / np.where(
            window_entry["entry_order"] == 1,
            window_entry["leader_aum_entry"],
            window_entry["follower_aum_entry"],
        ),
        2,
    )

    window_entry["d_post"] = 1 * (window_entry["distance_from_entry"] > 0)

    pivot_mer = (
        window_entry.drop_duplicates(subset=["ticker", "distance_from_entry"])
        .pivot(
            index=["distance_from_entry"],
            columns=["ticker"],
            values=[
                "management_fee",
                "mer_ratio",
                "aum_ratio",
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
    pivot_mer["sign_change"] = np.where(
        pivot_mer["entry_order"] == 1, pivot_mer["sign_change"], np.nan
    )
    pivot_mer = pivot_mer.merge(
        window_entry[["ticker", "index_id"]].drop_duplicates(), how="left"
    )

    group_means = pivot_mer.groupby("index_id")["sign_change"].transform("mean")
    pivot_mer["sign_change"] = pivot_mer["sign_change"].fillna(group_means)

    sizefigs_L = (22, 10)
    fig = plt.figure(facecolor="white", figsize=sizefigs_L)
    gs = gridspec.GridSpec(2, 2)

    # ---------
    ax = fig.add_subplot(gs[0, 0])
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

    ax = fig.add_subplot(gs[0, 1])
    ax = settings_plot(ax)

    sns.lineplot(
        data=pivot_mer[
            (pivot_mer.entry_order == 1) & (pivot_mer.sign_change != 0)
        ].dropna(subset="mer_ratio"),
        x="distance_from_entry",
        y="mer_ratio",
        errorbar=None,
        hue="sign_change",
        hue_order=[-1, 1],
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

    ax = fig.add_subplot(gs[1, 0])
    ax = settings_plot(ax)

    sns.lineplot(
        data=pivot_mer[
            (pivot_mer.entry_order == 1) & (pivot_mer.sign_change.isin([1, -1]))
        ],
        x="distance_from_entry",
        y="aum_ratio",
        errorbar=None,
        hue="sign_change",
        hue_order=[-1, 1],
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
    plt.title(
        "Panel (c): Heterogeneity in incumbent AUM dynamics around entry", fontsize=20
    )

    ax = fig.add_subplot(gs[1, 1])
    ax = settings_plot(ax)

    sns.lineplot(
        data=pivot_mer[
            (pivot_mer.entry_order == 2) & (pivot_mer.sign_change.isin([1, -1]))
        ],
        x="distance_from_entry",
        y="aum_ratio",
        errorbar=None,
        hue="sign_change",
        hue_order=[-1, 1],
        palette=["b", "r"],
        lw=2,
    )

    plt.axvline(x=0, c="k", ls="--", lw=2)
    plt.text(2, 6, "Follower entry", fontsize=20, ha="left", va="bottom")

    plt.xlabel("Days from entry", fontsize=20)
    plt.ylabel("Normalized AUM", fontsize=20)
    ax.legend(
        title="Incumbent fee",
        fontsize=16,
        title_fontsize=18,
        frameon=False,
        labels=["Higher after entry", "Lower after entry"],
    )
    plt.title(
        "Panel (d): Heterogeneity in entrant AUM dynamics around entry", fontsize=20
    )

    plt.tight_layout(pad=2)
    plt.savefig("../output/entry_dynamics.png", bbox_inches="tight")
