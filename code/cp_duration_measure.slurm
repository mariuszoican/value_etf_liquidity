#!/bin/bash
#SBATCH -J cp_duration
#SBATCH --array=0-1000                    # how many tasks in the array
#SBATCH -c 1                             # one CPU core per task
#SBATCH -t 0-4:00:00
#SBATCH -o ../logs/cp_duration-%a.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=marius.zoican@rotman.utoronto.ca
#SBATCH -p standard
#SBATCH --mem=80000

# Load software
# Load software
module load StdEnv/2020
module load python/3.9.6

# Run python script with a command line argument
python -u cp_duration_measure.py $SLURM_ARRAY_TASK_ID
