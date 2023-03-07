// import delimited "D:\ResearchProjects\kpz_etfliquidity\data\etf_panel_processed.csv", clear 
import delimited "D:\Research\kpz_etfliquidity\data\etf_panel_processed.csv", clear 

reghdfe mgr_duration highfee ratio_tii stock_tweets marketing_fee_bps  , absorb(index quarter) vce(cl index quarter)
reghdfe mgr_intensity highfee ratio_tii stock_tweets marketing_fee_bps  , absorb(index quarter) vce(cl index quarter)
