# The Value of ETF Liquidity

## Build and merge 13F urgency measures

1. Run `code/estimation_heterogeneity.py` to take raw 13F filings data (in `data/13FData.csv.gz`) and build a measure of
   urgency at manager level (saved in `data/manager_urgency.csv`), as the absolute slope of % change in ETF exposure on 
   ETF return (net of fixed effects). NAVs are adjusted for splits using CFACPR in CRSP data (`data/NAV_adjustments.csv.gz`).
2. Run `code/measure_analysis.py` to aggregate manager urgency at ETF and index level (saves in `data/urgency_measures.csv`, 
   and `../data/ix_urgency_measures.csv` respectively, as well as `data/all_urgency_measures.csv`).

## Run regressions
3. Run `code/merge_aum_data.py` to merge daily leader AUM data in `regressions/excel_panels` with panel around follower entry.
4. Run `regressions/etf_liquidity_regressions.sas` to generate all tables in `regressions/output`


## Generate plots

5. `code/theory_figure.py` for figures of investor arrival rate, comparative statics, welfare.
6. `code/plot_bubbles.py` for scatter plot of MER against liquidity
7. `code/plot_distribution_urgency.py` for histogram of empirical urgency measure
8. `code/plot_sequence_entry.py` for bar plot of average ETF urgency depending on entry sequence
9. `code/plot_industry_structure.py` for bar plot of index heterogeneity depending on multi-ETF index
10. `code/plot_entry_analysis.py` for bar plots with before/after entry measures for the leader ETF 

