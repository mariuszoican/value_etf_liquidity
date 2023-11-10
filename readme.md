# Code for "The Value of ETF Liquidity"

## Compute trading needs measures at manager-quarter level
1. `get_13F_CRSP_data.py`:
   * Connects to WRDS and downloads 13F data from Thomson Reuters from 12/31/2011 until present day. Saves the file in `data/data_13F.csv.gz`.
   * Also downloads and saves CRSP pricing data as `data/data_crsp.csv.gz`.
3. `urgency_measure_RR/cp_duration_slurm.py` **(TO BE EXECUTED ON MULTI-CORE NODE)**: Computes Cremers and Pareek (2016, JFE) measure of stock duration for each manager-stock-quarter.
   * Code designed to be executed on Rotman Research Node or equivalent SLURM machine.
   * The duration file is copied back to the repo as `data/duration_13F.csv.gz`
5. `urgency_measure_RR/merge_frequency_bushee_data`. Merges quarterly duration measures with Bushee's investor classification in `data/iiclass.csv`. Saves as `data/manager_panel.csv.gz`. Produces figure `output/tradingrate_by_tax.png`.

## Aggregate trading needs measures at ETF-quarter level.
4. `sample_13F_ETF`: gets the top 2 ETF by AUM and selects the 13F entries pertaining to ETF holdings between 2016Q1 and 2020Q4.  Saves ETF-only 13F data as `data_13F_ETFonly_RR.csv.gz` and the list of tickers as `list_tickers_etf.csv`.
4. `etf_traderates.py`
