import wrds
import pandas as pd
import numpy as np
import datetime as dt

conn = wrds.Connection(wrds_username="mazoican")  # login to WRDS account

panel = pd.read_csv("../../data/etf_panel_raw.csv", index_col=0)
list_tickers = panel.ticker.drop_duplicates().tolist()

print("Connection successful. Get Intraday Spread Indicators")

data_spread = conn.raw_sql(
    f""" SELECT EffectiveSpread_Dollar_Ave 
        FROM taqmsec.wrds_iid_2023
        WHERE DATE>='12/31/2010' AND  symbol IN {tuple(list_tickers)}"""
)

print(f"Data collected. Saving {len(data_spread)} observations...")

# data13f = data13f.dropna(subset=["cusip", "ticker"])
# data13f["quarter"] = data13f["rdate"].dt.year * 10 + data13f["rdate"].dt.quarter
# data13f.to_csv("../../data/data_13F_RR_complete.csv.gz", compression="gzip")

gg = """EffectiveSpread_Percent_Ave EffectiveSpread_Dollar_DW  EffectiveSpread_Dollar_SW  EffectiveSpread_Percent_DW EffectiveSpread_Percent_SW
            DollarRealizedSpread_LR_Ave PercentRealizedSpread_LR_Ave DollarPriceImpact_LR_Ave PercentPriceImpact_LR_Ave DollarRealizedSpread_LR_SW  DollarRealizedSpread_LR_DW PercentRealizedSpread_LR_SW
            PercentRealizedSpread_LR_DW DollarPriceImpact_LR_SW DollarPriceImpact_LR_DW PercentPriceImpact_LR_SW PercentPriceImpact_LR_DW"""
