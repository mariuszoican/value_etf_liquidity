import wrds
from hydra import compose, initialize
from omegaconf import OmegaConf
import pandas as pd
import numpy as np
import boto3
import datetime as dt
from scipy.stats.mstats import winsorize


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
    # data_etfg = pd.read_csv(
    #     f"../data/etfg_industry_{today}.csv.gz", index_col=0, parse_dates=["as_of_date"]
    # )

    s3_client = boto3.client("s3")
    data_etfg = aws_load_csv(
        "etfindustrydata", f"etfg_industry_{today}.csv.gz", s3_client
    )
    print("Data loaded. Start filtering...")

    list_exclude = [
        "SPLG",
        "SPSM",
        "IVV",
        "IJH",
        "IJR",
        "SCIJ",
        "SCIX",
        "RFG",
        "RFV",
        "GDX",
        "GDXJ",
    ]

    # apply simple filters
    filtered_etfg = data_etfg[
        (data_etfg["asset_class"] == "Equity")
        & (data_etfg["is_levered"] == 0)
        & (data_etfg["is_active"] == 0)
        & (data_etfg["is_etn"] == 0)
        & (data_etfg["as_of_date"] >= dt.datetime(2016, 1, 1))
        & (data_etfg["as_of_date"] <= dt.datetime(2020, 12, 31))
        & (~data_etfg["composite_ticker"].isin(list_exclude))
    ]

    # number of ETFs tracking the same benchmark for a given date
    filtered_etfg["count_etfs_benchmark"] = filtered_etfg.groupby(
        ["as_of_date", "primary_benchmark"]
    ).transform("count")["composite_ticker"]
    # filter out ETFs with only one ETF tracking the same benchmark
    filtered_etfg = filtered_etfg[filtered_etfg["count_etfs_benchmark"] > 1]

    # rank ETFs by AUM and keep only the top 2
    filtered_etfg = filtered_etfg.groupby(
        ["primary_benchmark", "as_of_date"], group_keys=False
    ).apply(lambda x: x.nlargest(2, "aum"))

    # keep only ETFs with >= 2.5 years since inception
    filtered_etfg["inception_date"] = filtered_etfg["inception_date"].apply(
        lambda x: dt.datetime.strptime(x, "%Y-%m-%d")
    )

    filtered_etfg["min_date"] = filtered_etfg.groupby("composite_ticker")[
        "as_of_date"
    ].transform("min")
    filtered_etfg["max_date"] = filtered_etfg.groupby("composite_ticker")[
        "as_of_date"
    ].transform("max")

    # filtered_etfg = filtered_etfg[
    #     (filtered_etfg["as_of_date"] - filtered_etfg["inception_date"])
    #     >= dt.timedelta(days=2.5 * 364)
    # ]

    filtered_etfg = filtered_etfg[
        (filtered_etfg["max_date"] - filtered_etfg["min_date"])
        >= dt.timedelta(days=2.5 * 364)
    ]

    # remove index days where competing ETFs have the same fee
    filtered_etfg["same_fee"] = filtered_etfg.groupby(
        ["primary_benchmark", "as_of_date"]
    )["management_fee"].transform(lambda x: 1 if x.nunique() == 1 else 0)
    filtered_etfg = filtered_etfg[filtered_etfg["same_fee"] == 0]

    filtered_etfg.to_csv(
        "df_R1_replication_daily.csv.gz", compression="gzip", index=False
    )

    # winsorize spread at 99% and remove negative spreads
    filtered_etfg = filtered_etfg[filtered_etfg["bid_ask_spread"] >= 0]
    filtered_etfg["spread_win"] = winsorize(
        filtered_etfg["bid_ask_spread"], limits=(0.01, 0.01)
    )

    # winsorize discount/premium at 99% and take absolute value as in the R1 report
    filtered_etfg["discount_win"] = winsorize(
        filtered_etfg["discount_premium"], limits=(0.01, 0.01)
    )
    filtered_etfg["discount_win_abs"] = np.abs(filtered_etfg["discount_win"])
    filtered_etfg = filtered_etfg[filtered_etfg.discount_win_abs < 0.5]

    # compute quarter
    filtered_etfg["quarter"] = filtered_etfg["as_of_date"].dt.to_period("Q")

    # group by quarter, primary_benchmark, composite_ticker
    filtered_etfg_q = filtered_etfg.groupby(
        ["quarter", "primary_benchmark", "composite_ticker"]
    ).agg(
        {
            "aum": ["mean"],
            "avg_daily_trading_volume": ["mean"],
            "management_fee": ["mean"],
            "other_expenses": ["mean"],
            "total_expenses": ["mean"],
            "fee_waivers": ["mean"],
            "net_expenses": ["mean"],
            "spread_win": ["median"],
            "discount_win_abs": ["median"],
        }
    )
    filtered_etfg_q.columns = [
        "_".join(col) for col in filtered_etfg_q.columns.to_flat_index()
    ]
    filtered_etfg_q.columns = [
        col.replace("_mean", "").replace("_median", "")
        for col in filtered_etfg_q.columns
    ]
    filtered_etfg_q["volumeshare"] = filtered_etfg_q.groupby(
        ["quarter", "primary_benchmark"]
    )["avg_daily_trading_volume"].transform(lambda x: x / x.sum())
    filtered_etfg_q["aumshare"] = filtered_etfg_q.groupby(
        ["quarter", "primary_benchmark"]
    )["aum"].transform(lambda x: x / x.sum())

    filtered_etfg_q["logvolume"] = np.log(filtered_etfg_q["avg_daily_trading_volume"])
    filtered_etfg_q["logaum"] = np.log(filtered_etfg_q["aum"])

    filtered_etfg_q["rank_fee"] = filtered_etfg_q.groupby(
        ["quarter", "primary_benchmark"]
    )["management_fee"].rank(method="dense")

    filtered_etfg_q["uniquevals"] = filtered_etfg_q.groupby(
        ["quarter", "primary_benchmark"]
    )["management_fee"].transform("nunique")

    filtered_etfg_q["rank_fee"] = np.where(
        filtered_etfg_q["uniquevals"] == 2, filtered_etfg_q["rank_fee"], np.nan
    )

    filtered_etfg_q["highfee"] = np.where(
        filtered_etfg_q["rank_fee"] == 2,
        1,
        np.where(filtered_etfg_q["rank_fee"] == 1, 0, np.nan),
    )

    filtered_etfg_q.reset_index(inplace=True)
    filtered_etfg_q.to_csv("df_R1_replication_quarterly.csv", index=False)
