import wrds
from hydra import compose, initialize
from omegaconf import OmegaConf
import pandas as pd
import numpy as np
import datetime as dt

if __name__ == "__main__":
    with initialize(version_base=None, config_path="../conf"):
        cfg = compose(config_name="config")

    conn = wrds.Connection(wrds_username=cfg.wrds_user)  # login to WRDS account

    print("Connection successful. Get 13F data for Thomson Reuters")

    gg

    data13f = conn.raw_sql(
        """ SELECT rdate, mgrno, mgrname, cusip, shares, ticker, prc, shrout2 FROM tr_13f.s34 
                            WHERE fdate>='12/31/2010' AND fdate<='6/30/2022' """,
        date_cols=["rdate"],
    )

    print(f"Data collected. Saving {len(data13f)} observations...")

    data13f = data13f.dropna(subset=["cusip", "ticker"])
    data13f["quarter"] = data13f["rdate"].dt.year * 10 + data13f["rdate"].dt.quarter
    data13f.to_csv(f"{cfg.data_folder}/data_13F.csv.gz", compression="gzip")

    # Get CRSP data
    # ------------------
    data_crsp = conn.raw_sql(
        """SELECT cusip, permno, date, prc FROM crsp_a_stock.msf
                            WHERE date>='3/30/2010' AND date<='12/30/2022'""",
        date_cols=["date"],
    )
    print(f"Data collected. Saving {len(data_crsp)} observations...")

    data_crsp["prc"] = np.where(data_crsp.prc < 0, -data_crsp.prc, data_crsp.prc)

    data_connect_crsp = conn.raw_sql(
        """select *
                            from crsp_a_ccm.ccm_lookup
                            """
    )
    data_connect_crsp["permno"] = data_connect_crsp["lpermno"]
    data_crsp = data_crsp.merge(
        data_connect_crsp[["permno", "tic"]], on="permno", how="left"
    )
    data_crsp = data_crsp.rename(columns={"tic": "ticker"})

    # get column with year-quarter
    data_crsp["quarter"] = data_crsp["date"].dt.year * 10 + data_crsp["date"].dt.quarter

    data_crsp.to_csv(f"{cfg.data_folder}/data_crsp.csv.gz", compression="gzip")

    # get ETFG data
    data_etfg = conn.raw_sql(
        """ SELECT as_of_date, composite_ticker, issuer, description, primary_benchmark, tax_classification, is_etn, asset_class, category, is_levered, is_active, 
        creation_fee, management_fee, other_expenses, total_expenses, fee_waivers, net_expenses, lead_market_maker FROM etfg_industry.industry
                        WHERE as_of_date>='1/1/2015' AND as_of_date<='3/1/2023' """,
        date_cols=["as_of_date"],
    )
    data_etfg.to_csv(f"{cfg.data_folder}/dummies_etfg.csv.gz", compression="gzip")
