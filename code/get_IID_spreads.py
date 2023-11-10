import wrds
import pandas as pd
import numpy as np
import datetime as dt

conn = wrds.Connection(wrds_username="mazoican")  # login to WRDS account

panel = pd.read_csv("../../data/etf_panel_raw.csv", index_col=0)
list_tickers = panel.ticker.drop_duplicates().tolist()

print("Connection successful. Get Intraday Spread Indicators")

list_variables = [
    "date",
    "sym_root",
    "quotedspread_dollar_tw",
    "quotedspread_percent_tw",
    "effectivespread_dollar_ave",
    "effectivespread_percent_ave",
    "effectivespread_dollar_dw",
    "effectivespread_dollar_sw",
    "effectivespread_percent_dw",
    "effectivespread_percent_sw",
    "dollarrealizedspread_lr_ave",
    "percentrealizedspread_lr_ave",
    "dollarpriceimpact_lr_ave",
    "percentpriceimpact_lr_ave",
    "dollarrealizedspread_lr_sw",
    "dollarrealizedspread_lr_dw",
    "percentrealizedspread_lr_sw",
    "percentrealizedspread_lr_dw",
    "dollarpriceimpact_lr_sw",
    "dollarpriceimpact_lr_dw",
    "percentpriceimpact_lr_sw",
    "percentpriceimpact_lr_dw",
]

data_spread = pd.DataFrame()

for year in range(2014, 2024):
    print(year)
    data_temp = conn.raw_sql(
        f""" SELECT *
            FROM taqmsec.wrds_iid_{str(year)}
            WHERE sym_root IN {tuple(list_tickers)}"""
    )

    print(f"Data collected. Saving {len(data_temp)} observations...")
    data_temp = data_temp[list_variables]
    data_temp = data_temp.rename(columns={"sym_root": "ticker"})

    data_spread = pd.concat([data_spread, data_temp], axis=0, ignore_index=True)

data_spread.to_csv("../../data/etf_spread_measures.csv")
