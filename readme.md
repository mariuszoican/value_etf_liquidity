## Instructions to Replicate the Results in "The Value of ETF Liquidity"
## Khomyn, Putnins, and Zoican (Review of Financial Studies)

1. **Replication of Regression Table `X`**:
   - Run the Stata code `regression_code/table_X.do` to generate the LaTeX table at `output/table_X.tex`.
   - The Stata code utilizes the following processed data panels included in the repository: `data/etf_panel_processed.csv`, `data/probit_data_processed.csv`, and `data/cs_panel.csv`.

2. **Replication of Figures**:
   - Use the Python code `code/theory_figure.py` for Figure 2.
   - Use the Python code `code/build_etf_panel.py` for Figures 3 through 6.
   - Use the Python code `code/figure_entry.py` for Figure 7.
   - Note: Figure 1 is a simple diagram that does not require data or numerical simulations.

3. **Replication of Data Cleaning Process and Variable Computation**:
   - Follow steps 1 through 6 in `readme.xlsx` sequentially. These steps correspond to Python codes listed within the file.
   - The `requirements.txt` file contains all necessary packages for the local Python environment.

### Additional Notes
1. **WRDS Data Access**:
   - Update the `wrds_user` parameter in the `conf/config.yaml` file with your own WRDS username.

2. **Stata Path Configuration**:
   - If your Stata installation path differs, update the path in the `conf/config.yaml` file accordingly.

3. **Cremers-Pareek Duration Measure Computation**:
   - The computation utilizes parallel processing through SLURM on a university cluster machine. While the SLURM code is included, you may need to adapt the syntax to suit your specific cluster setup.
