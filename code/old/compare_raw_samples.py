import wrds
from hydra import compose, initialize
from omegaconf import OmegaConf
import pandas as pd
import numpy as np
import boto3
import datetime as dt
from scipy.stats.mstats import winsorize
import warnings

warnings.filterwarnings("ignore")

clean_shorts = True
aws = False


def aws_load_csv(bucket_name, object, s3_client):
    import pandas as pd
    import io
    import gzip

    obj = s3_client.get_object(Bucket=bucket_name, Key=object, RequestPayer="requester")
    body_obj = obj["Body"].read()  # pull object / decode
    decompressed_data = gzip.decompress(body_obj)
    return pd.read_csv(io.BytesIO(decompressed_data))


# Keep only the top 2 ETFs by AUM in each index-date
def rank_group(df, k, in_column, out_column):
    df[out_column] = df[in_column].rank(method="dense", ascending=False) <= k
    return df


if __name__ == "__main__":
    with initialize(version_base=None, config_path="../conf"):
        cfg = compose(config_name="config")

    date_file = dt.datetime(2024, 4, 22)  # vintage of ETFG data
    today = date_file.strftime("%Y%m%d")
    print("Loading data:")

    if not aws:
        data_etfg = pd.read_csv(
            f"../data/etfg_industry_{today}.csv.gz",
            index_col=0,
            parse_dates=["as_of_date", "inception_date"],
        )
    else:
        s3_client = boto3.client("s3")
        data_etfg = aws_load_csv(
            "etfindustrydata", f"etfg_industry_{today}.csv.gz", s3_client
        )
        data_etfg["as_of_date"] = pd.to_datetime(data_etfg["as_of_date"])
        data_etfg["inception_date"] = pd.to_datetime(data_etfg["inception_date"])

    print("Data loaded. Start filtering...")

    data_etfg = data_etfg[
        ~(
            data_etfg["description"].apply(
                lambda x: (
                    ("Short" in str(x))
                    | ("short" in str(x))
                    | ("Bear" in str(x))
                    | ("bear" in str(x))
                )
            )
        )
    ]

    list_exclude = [
        "SPLG",
        "SPSM",
        "SCIJ",
        "SCIX",
        "RFG",
        "RFV",
        "GDX",
        "GDXJ",
    ]

    # apply simple filters for exclusion ETFs and time period
    filtered_etfg = data_etfg[
        (data_etfg["asset_class"] == "Equity")
        & (data_etfg["is_levered"] == 0)
        & (data_etfg["is_active"] == 0)
        & (data_etfg["is_etn"] == 0)
        & (data_etfg["as_of_date"] >= dt.datetime(2016, 1, 1))
        & (data_etfg["as_of_date"] <= dt.datetime(2020, 12, 31))
        & (~data_etfg["composite_ticker"].isin(list_exclude))
        & ~(data_etfg["primary_benchmark"].str.contains("Not Applicable", na=False))
    ]

    # Rank ETFs by AUM and keep only the top 2
    filtered_etfg["count_etfs_benchmark"] = filtered_etfg.groupby(
        ["as_of_date", "primary_benchmark"]
    ).transform("count")["composite_ticker"]
    filtered_etfg = filtered_etfg[filtered_etfg["count_etfs_benchmark"] >= 2]
    print(f"Filtered sample: {filtered_etfg['composite_ticker'].nunique()} tickers")

    raw_from_marta = pd.read_csv("../raw_panels/etf_panel_raw.csv")
    print(
        f"Marta's raw sample: {raw_from_marta[raw_from_marta.d_sameind == 1]['ticker'].nunique()} tickers"
    )

    list_raw = set(filtered_etfg["composite_ticker"].unique())
    list_marta = set(raw_from_marta[raw_from_marta.d_sameind == 1]["ticker"].unique())
    list_marta_diff_ix = set(
        raw_from_marta[raw_from_marta.d_sameind == 0]["ticker"].unique()
    )

    difference_tickers = (
        filtered_etfg[
            filtered_etfg.composite_ticker.isin(
                list_raw.difference(list_marta).difference(list_marta_diff_ix)
            )
        ][["composite_ticker", "primary_benchmark"]]
        .drop_duplicates(subset="composite_ticker", keep="first")
        .sort_values(by=["primary_benchmark"])
        .reset_index(drop=True)
    )

    sum_stats_missing_sample = (
        filtered_etfg[
            filtered_etfg.composite_ticker.isin(
                difference_tickers.composite_ticker.unique()
            )
        ]
        .groupby("composite_ticker")
        .agg({"as_of_date": ["count", "min", "max"], "inception_date": "median"})
    )
    sum_stats_missing_sample.columns = [
        "_".join(col) for col in sum_stats_missing_sample.columns.to_flat_index()
    ]
    sum_stats_missing_sample["max_min_day"] = (
        sum_stats_missing_sample["as_of_date_max"]
        - sum_stats_missing_sample["as_of_date_min"]
    )
    sum_stats_missing_sample["max_min_day"] = sum_stats_missing_sample[
        "max_min_day"
    ].dt.days
    sum_stats_missing_sample["time_in_sample"] = 1 * (
        sum_stats_missing_sample["max_min_day"] >= 2.5 * 365
    )
    sum_stats_missing_sample.to_csv("tickers_not_in_marta_raw.csv")
