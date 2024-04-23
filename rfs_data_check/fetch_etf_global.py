import wrds
from hydra import compose, initialize
from omegaconf import OmegaConf
import pandas as pd
import numpy as np
import datetime as dt
import boto3
import os


def save_data(fname, bucket_name, destination, s3_client):
    s3_client.upload_file(fname, bucket_name, destination)


if __name__ == "__main__":
    with initialize(version_base=None, config_path="../conf"):
        cfg = compose(config_name="config")

    s3_client = boto3.client("s3")

    conn = wrds.Connection(wrds_username=cfg.wrds_user)  # login to WRDS account

    print("Connection successful. Get ETFG data for Thomson Reuters")

    # get full ETFG data
    print("Get full ETFG data")
    data_etfg = conn.raw_sql(
        """ SELECT * FROM etfg_industry.industry
                        """,
        date_cols=["as_of_date"],
    )

    today = dt.datetime.now().strftime("%Y%m%d")
    print("Data collected. Saving...")
    data_etfg.to_csv(f"../data/etfg_industry_{today}.csv.gz", compression="gzip")

    save_to_s3 = 1

    if save_to_s3:
        save_data(
            f"../data/etfg_industry_{today}.csv.gz",
            "etfindustrydata",
            f"etfg_industry_{today}.csv.gz",
            s3_client,
        )
        os.remove(f"../data/etfg_industry_{today}.csv.gz")
