# The Value of ETF Liquidity  (RFS Revise & Resubmit)

## Compute trading needs measure at manager-quarter level
1. `urgency_measure_RR/get_13F_data.py`: Connects to WRDS and downloads 13F data from Thomson Reuters from 12/31/2011 until present day. Saves the file in `data/data_13F_updateRR.csv.gz`.
2. `urgency_measure_RR/trade_frequency_measure.py`. Compute our measure of trading needs based on intra-quarter position volatility (i.e., residual standard deviation from regressing portfolio returns on fixed-weights portfolio returns). Starts from manager-level 13F data in `data/data_13F_updateRR.csv.gz`. Saves file with manager-quarter intensity at `data/trading_intensity_mgrno_RR.csv.gz`.
3. `urgency_measure_RR/merge_frequency_bushee_data`. Merges trade intensity file at `data/trading_intensity_mgrno_RR.csv.gz` with Bushee's investor classification in `data/iiclass.csv` and saves as `data/manager_panel.csv.gz`. Produces figure `output/tradingrate_by_tax.png`.

## Aggregate trading needs measures at ETF-quarter level.
4. `sample_13F_ETF`: gets the top 2 ETF by AUM and selects the 13F entries pertaining to ETF holdings between 2016Q1 and 2020Q4. 
4. `etf_traderates.py`