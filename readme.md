# The Value of ETF Liquidity

## Build and merge 13F urgency measures

1. Run `code/estimation_heterogeneity.py` to take raw 13F filings data (in `data/13FData.csv.gz`) and build a measure of
   urgency at manager level (saved in `data/manager_urgency.csv`), as the absolute slope of % change in ETF exposure on 
   ETF return (net of fixed effects). NAVs are adjusted for splits using CFACPR in CRSP data (`data/NAV_adjustments.csv.gz`).
2. Run `code/measure_analysis.py` to aggregate manager urgency at ETF and index level (saves in `data/urgency_measures.csv`, 
   and `../data/ix_urgency_measures.csv` respectively, as well as `data/all_urgency_measures.csv`).
3. Run `code/merge_urgency.py` to merge urgency measures into `data/etf_paneldata.csv` and save as `data/etf_panel_merged.csv`.
4. Run `code/pivot_differences.py` to generate leader-follower differentials (for market shares, spreads, MER)

## Build VIX measure
5. Run `code/vix_analysis.py` to compute VIX innovations and merge with ETF panel data.

## Generate plots

6. `code/theory_figure.py` for figures of investor arrival rate, comparative statics, welfare.
7. `code/plot_bubbles.py` for scatter plot of MER against liquidity
8. `code/plot_distribution_urgency.py` for histogram of empirical urgency measure
9. `code/plot_sequence_entry.py` for bar plot of average ETF urgency depending on entry sequence
10. `code/plot_industry_structure.py` for bar plot of index heterogeneity depending on multi-ETF index
11. `code/plot_entry_analysis.py` for bar plots with before/after entry measures for the leader ETF 
