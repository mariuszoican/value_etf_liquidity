import os
from hydra import compose, initialize
from omegaconf import OmegaConf
import pandas as pd


if __name__ == "__main__":
    with initialize(version_base=None, config_path="../conf"):
        cfg = compose(config_name="config")

    list_files = os.listdir(f"{cfg.data_folder}/temp")

    df_duration = pd.DataFrame()

    k = 1
    for f in list_files:
        print(k)
        temp = pd.read_csv(f"{cfg.data_folder}/temp/{f}")
        df_duration = pd.concat([df_duration, temp], ignore_index=True)
        k += 1

    print("Save")
    list_columns = [
        "mgrno",
        "mgrname",
        "quarter",
        "ticker",
        "shares",
        "shrout2",
        "duration",
    ]

    data_crsp = pd.read_csv(f"{cfg.data_folder}/data_crsp.csv.gz", compression="gzip")
    data_crsp = data_crsp.drop_duplicates(subset=["ticker", "quarter"], keep="last")
    data_crsp = data_crsp.rename(columns={"prc": "prc_crsp"})

    df_duration_trim = df_duration[list_columns]
    df_duration_trim_2 = df_duration_trim.merge(
        data_crsp[["ticker", "quarter", "prc_crsp"]],
        on=["ticker", "quarter"],
        how="left",
    )
    df_duration_trim_2 = df_duration_trim_2.dropna()
    df_duration_trim_2.to_csv(f"{cfg.data_folder}/duration_13F.csv.gz")

    ix = 1
    for f in list_files:
        print(ix)
        os.remove(f"{cfg.data_folder}/temp/{f}")
        ix += 1
