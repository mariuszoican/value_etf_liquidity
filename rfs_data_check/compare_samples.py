import wrds
from hydra import compose, initialize
from omegaconf import OmegaConf
import pandas as pd
import numpy as np
import datetime as dt
from scipy.stats.mstats import winsorize


# Keep only the top 2 ETFs by AUM in each index-date
def rank_group(df, k, in_column, out_column):
    df[out_column] = df[in_column].rank(method="dense", ascending=False) <= k
    return df


if __name__ == "__main__":
    with initialize(version_base=None, config_path="../conf"):
        cfg = compose(config_name="config")

    auto_panel = pd.read_csv(
        "df_R1_replication_quarterly_longbenchmark.csv",
        index_col=0,
        parse_dates=["quarter"],
    )
    original_panel = pd.read_csv(
        cfg.data_folder + "/etf_panel_processed.csv", index_col=0
    )
    # keep only exact index matches
    original_panel = original_panel[original_panel.d_sameind == 1]

    exact_matches_paper = sorted(original_panel.ticker.unique())
    exact_matches_replication = sorted(auto_panel.composite_ticker.unique())

    # tickers in both sets
    both_have = set(exact_matches_replication).intersection(set(exact_matches_paper))
    # tickers in paper but not in replication
    paper_only = set(exact_matches_paper).difference(set(exact_matches_replication))
    # tickers in replication but not in paper
    replication_only = set(exact_matches_replication).difference(
        set(exact_matches_paper)
    )
