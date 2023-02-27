# The Value of ETF Liquidity  (RFS Revise & Resubmit)

## Compute trading needs measure at manager-quarter level
1. `urgency_measure_RR/get_13F_data.py`: Connects to WRDS and downloads 13F data from Thomson Reuters from 12/31/2011 until present day. Saves the file in `data/data_13F_updateRR.csv.gz`.
2. `urgency_measure_RR/trade_frequency_measure.py`. Compute our measure of trading needs based on intra-quarter position volatility (i.e., residual standard deviation from regressing portfolio returns on fixed-weights portfolio returns). Starts from manager-level 13F data in `data/data_13F_updateRR.csv.gz`.