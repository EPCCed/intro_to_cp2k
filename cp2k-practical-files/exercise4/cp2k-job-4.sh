#!/bin/bash

#SBATCH --job-name=CP2K_test
#SBATCH --nodes=1
#SBATCH --tasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --time=00:20:00

#SBATCH --account=ta042
#SBATCH --partition=standard
#SBATCH --qos=standard
#SBATCH --export=all

# Load the relevant CP2K module
# Ensure OMP_NUM_THREADS is consistent with cpus-per-task above
# Launch the executable

module load epcc-job-env
module load cp2k/8.1

echo $LD_LIBRARY_PATH

export OMP_NUM_THREADS=1
export OMP_PLACES=cores

srun --hint=nomultithread --distribution=block:block cp2k.psmp -i input_H2O.inp
