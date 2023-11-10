import pandas as pd
from hydra import compose, initialize
from omegaconf import OmegaConf
import numpy as np
import warnings
import sys

warnings.filterwarnings("ignore")

if __name__ == "__main__":
    with initialize(version_base=None, config_path="../conf"):
        cfg = compose(config_name="config")

    # Define the start and end year
    start_year = 2010
    end_year = 2022

    # Generate the list of quarter identifiers
    list_quarters = [
        year * 10 + quarter
        for year in range(start_year, end_year + 1)
        for quarter in range(1, 5)
    ][:-2]

    quarters = pd.DataFrame(list_quarters, columns=["quarter"])

    # load raw 13F data
    print("Load (raw) 13F data")
    data13f = pd.read_csv(f"{cfg.data_folder}/data_13F.csv.gz", index_col=0)

    # keep only the last report for any given quarter
    data13f = data13f.drop_duplicates(subset=["mgrno", "cusip", "quarter"], keep="last")

    data13f = data13f[["mgrno", "mgrname", "quarter", "ticker", "shares", "shrout2"]]

    # count number of reporting quarters by manager
    mgr_count = (
        data13f.groupby(["mgrno", "quarter"])
        .count()["rdate"]
        .groupby("mgrno")
        .count()
        .reset_index()
    )
    mgr_count = mgr_count.rename(columns={"rdate": "mgr_quarter_count"})
    data13f = data13f.merge(mgr_count, on="mgrno", how="left")

    data13f = data13f[
        data13f.mgr_quarter_count >= cfg.min_quarters
    ]  # keep only managers with "min_quarters" (8) quarters or more

    # get list for slurm
    def partition_list(lst, k):
        n = len(lst)
        quotient = n // k
        remainder = n % k
        partition_sizes = [
            quotient + 1 if i < remainder else quotient for i in range(k)
        ]
        return [
            lst[sum(partition_sizes[:i]) : sum(partition_sizes[: i + 1])]
            for i in range(k)
        ]

    # get list of managers
    list_managers = data13f.mgrno.drop_duplicates().tolist()

    # partition the list of managers
    partition_managers = partition_list(list_managers, 1000)

    # idx=int(sys.argv[1])
    idx = 0

    sample = data13f[data13f.mgrno.isin(partition_managers[idx])]

    def compute_duration(temp):
        temp = temp.merge(quarters, on="quarter", how="outer")
        temp["shares"] = temp["shares"].fillna(0)
        temp = temp.fillna(method="ffill")
        temp = temp.sort_values(by="quarter", ascending=True)

        temp["pshare"] = temp["shares"] / (10 * temp["shrout2"])  # percentage shares
        temp["pshare_start_window"] = temp["pshare"].shift(w)  # proxy for H

        temp["pshare_start_window"] = temp["pshare_start_window"].fillna(0)

        temp["pshare_diff"] = temp["pshare"].diff()  # proxy for alpha
        temp["pshare_diff_bought"] = np.where(
            temp["pshare_diff"] > 0, temp["pshare_diff"], 0
        )

        temp["bought_diff"] = temp["pshare_diff_bought"].rolling(w).sum()  # proxy for B
        temp["HB"] = temp["bought_diff"] + temp["pshare_start_window"]  # proxy for H+B

        # define weights
        weights = list(range(w - 1, -1, -1))
        # define the custom function for rolling mean with weights

        def weighted_sum(x):
            return np.sum(x * weights)

        temp["rolling_alpha"] = (
            temp["pshare_diff"].rolling(window=len(weights)).apply(weighted_sum)
        )

        # compute duration
        temp["duration"] = (
            temp["rolling_alpha"] / temp["HB"]
            + (w - 1) * temp["pshare_start_window"] / temp["HB"]
        )
        temp["duration"] = np.where(temp["shares"] == 0, 0, temp["duration"])

        return temp[temp["duration"] > 0]

    w = cfg.rolling_window_cremers
    data = sample.groupby(["mgrno", "ticker"]).apply(lambda x: compute_duration(x, w))
    data = data.reset_index(drop=True)

    print("Save data!")
    data.to_csv(f"{cfg.data_folder}/duration_13F.csv.gz" % idx, compression="gzip")
