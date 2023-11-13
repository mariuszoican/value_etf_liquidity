import pandas as pd
from hydra import compose, initialize
from omegaconf import OmegaConf
import numpy as np
import datetime as dt
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib import cm, rcParams
from matplotlib import rc, font_manager
import matplotlib.patches as mpatches
import matplotlib.gridspec as gridspec
import statsmodels.formula.api as smf  # load the econometrics package
import warnings

warnings.filterwarnings("ignore")
from scipy.stats.mstats import winsorize
import seaborn as sns
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()

plt.rcParams.update(
    {"text.usetex": True, "font.family": "sans-serif", "font.sans-serif": ["Helvetica"]}
)

sizeOfFont = 18
ticks_font = font_manager.FontProperties(size=sizeOfFont)


def settings_plot(ax):
    for label in ax.get_xticklabels():
        label.set_fontproperties(ticks_font)
    for label in ax.get_yticklabels():
        label.set_fontproperties(ticks_font)
    ax.spines["right"].set_visible(False)
    ax.spines["top"].set_visible(False)
    return ax


if __name__ == "__main__":
    with initialize(version_base=None, config_path="../conf"):
        cfg = compose(config_name="config")

    # load index data
    probit_file = pd.read_csv(f"{cfg.raw_folder}/probit_raw.csv")
    # load ticker to index correspondence file which includes launch order
    meta = pd.read_csv(f"{cfg.raw_folder}/all_tickers_meta.csv", index_col=0)[
        ["ticker", "index"]
    ]
    meta = meta.rename(columns={"index": "index_id"})

    crsp_data = pd.read_csv("../data/crsp_all_etf_volume.gz", index_col=0)
    ggg
    crsp_data = crsp_data.rename(columns={"TICKER": "ticker"})
    crsp_data["price"] = np.where(
        crsp_data["PRC"] < 0, -crsp_data["PRC"], crsp_data["PRC"]
    )
    crsp_data["relative_spread"] = (
        10000
        * 2
        * (crsp_data["ASK"] - crsp_data["BID"])
        / (crsp_data["ASK"] + crsp_data["BID"])
    )
    crsp_data["relative_spread"] = np.where(
        crsp_data["relative_spread"] <= 0,
        np.nan,
        np.where(
            crsp_data["relative_spread"] >= 10000, np.nan, crsp_data["relative_spread"]
        ),
    )
    crsp_data["as_of_date"] = crsp_data["date"].apply(
        lambda x: dt.datetime.strptime(x, "%Y-%m-%d")
    )
    crsp_data["volume_usd"] = crsp_data["PRC"] * crsp_data["VOL"]

    wrds_file = pd.read_csv(
        "../data/etf_all_indices_data.csv.gz", compression="gzip", index_col=0
    )
    wrds_file["as_of_date"] = wrds_file["as_of_date"].apply(
        lambda x: dt.datetime.strptime(x, "%Y-%m-%d")
    )
    wrds_file = wrds_file[
        (wrds_file["as_of_date"] >= dt.datetime(2016, 1, 1))
        & (wrds_file["as_of_date"] <= dt.datetime(2020, 12, 31))
    ]
    wrds_file = wrds_file.rename(columns={"composite_ticker": "ticker"})
    wrds_file = wrds_file.merge(meta, on="ticker", how="left")
    wrds_file = wrds_file.merge(
        crsp_data[["as_of_date", "ticker", "relative_spread", "volume_usd", "price"]],
        on=["as_of_date", "ticker"],
        how="left",
    )

    wrds_file["aum_index"] = wrds_file.groupby(["index_id", "as_of_date"])[
        "aum"
    ].transform(sum)
    wrds_file["num_hold_index"] = wrds_file.groupby(["index_id", "as_of_date"])[
        "num_holdings"
    ].transform(np.mean)
    wrds_file["volume_index"] = wrds_file.groupby(["index_id", "as_of_date"])[
        "volume_usd"
    ].transform(sum)
    wrds_file["spread_index"] = wrds_file.groupby(["index_id", "as_of_date"])[
        "relative_spread"
    ].transform(np.mean)

    mean_data = (
        wrds_file.groupby("index_id")
        .mean()[["aum_index", "num_hold_index", "volume_index", "spread_index"]]
        .reset_index()
    )

    data13f = pd.read_csv("../data/data_13F_RR_complete.csv.gz", index_col=0)
    data13f = data13f[data13f["rdate"].apply(lambda x: x[0:4] == "2020")]
    data13f = data13f[data13f.ticker.isin(meta["ticker"].tolist())]

    data13f = data13f.merge(meta[["ticker", "index_id"]], on="ticker", how="left")
    # Bushee data on manager classification
    mgr_classification = pd.read_csv("../data/iiclass.csv")

    def transient(x):
        if x == "TRA":
            return x
        elif x in ["QIX", "DED"]:
            return "non-TRA"
        else:
            return np.nan

    mgr_classification["transient_investor"] = mgr_classification["horizon_perma"].map(
        transient
    )
    mgr_classification["tax_extend"] = mgr_classification.groupby("permakey")[
        "tax_extend"
    ].apply(lambda x: x.fillna(method="ffill"))

    data13f = data13f.merge(
        mgr_classification[["mgrno", "horizon_perma", "tax_extend"]],
        on="mgrno",
        how="left",
    )
    data13f["dollar_pos"] = data13f["shares"] * data13f["prc"]

    tax_sensitivity = (
        data13f.groupby(["index_id", "tax_extend"])
        .agg({"dollar_pos": sum})
        .reset_index()
    )
    tax_sensitivity["total_shares_sample"] = tax_sensitivity.groupby(
        [
            "index_id",
        ]
    )[
        "dollar_pos"
    ].transform(sum)
    tax_sensitivity["ratio_tii"] = (
        tax_sensitivity["dollar_pos"] / tax_sensitivity["total_shares_sample"]
    )
    tax_sensitivity = tax_sensitivity[tax_sensitivity.tax_extend == "TII"]
    tax_sensitivity = tax_sensitivity[["index_id", "ratio_tii"]]

    transient = (
        data13f.groupby(["index_id", "horizon_perma"])
        .agg({"dollar_pos": sum})
        .reset_index()
    )
    transient["total_shares_sample"] = transient.groupby(
        [
            "index_id",
        ]
    )[
        "dollar_pos"
    ].transform(sum)
    transient["ratio_tra"] = transient["dollar_pos"] / transient["total_shares_sample"]
    transient = transient[transient.horizon_perma == "TRA"]
    transient = transient[["index_id", "ratio_tra"]]

    probit_file_2 = probit_file.merge(tax_sensitivity, on="index_id", how="left").merge(
        transient, on="index_id", how="left"
    )
    probit_file_2 = probit_file_2.drop(
        ["turnover_perc", "numholdings_", "aum_index", "dvol", "spread_bps"], axis=1
    )
    probit_file_2 = probit_file_2.merge(mean_data, on="index_id", how="left")

    probit_file_2.to_csv("../data/probit_data_processed.csv")
