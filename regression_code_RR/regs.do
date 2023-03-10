// import delimited "D:\ResearchProjects\kpz_etfliquidity\data\etf_panel_processed.csv", clear 
import delimited "D:\Research\kpz_etfliquidity\data\etf_panel_processed.csv", clear 

reghdfe mgr_duration_stable highfee time_existence time_since_first , absorb(index quarter) vce(cl quarter)
reghdfe mgr_duration_stable  highfee log_aum_index d_uit lend_byaum_bps  marketing_fee_bps stock_tweets time_existence time_since_first , absorb(index quarter) vce(cl quarter)