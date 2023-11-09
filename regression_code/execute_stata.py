import subprocess
import sys
from hydra import compose, initialize
from omegaconf import OmegaConf


if __name__ == "__main__":
    with initialize(version_base=None, config_path="../conf"):
        cfg = compose(config_name="config")

    # Define path to Stata
    stata_path = cfg.stata_path

    # Define path to do-file
    dofile_path = sys.argv[1]

    # Run the Stata file
    subprocess.run([stata_path, "-e", "do", dofile_path])
