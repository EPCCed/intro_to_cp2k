#!/bin/bash

#SBATCH --job-name=CP2K_test
#SBATCH --nodes=1
#SBATCH --tasks-per-node=64
#SBATCH --cpus-per-task=2
#SBATCH --time=00:20:00
#SBATCH --account=ta154
#SBATCH --partition=standard
#SBATCH --export=none

# Load the relevant CP2K module
module load cp2k/cp2k-2023.2 

# Ensure OMP_NUM_THREADS is consistent with cpus-per-task above
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Set thread affinity as recommended
export OMP_PLACES=cores

# Ensure cpus-per-task are passed to srun
export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK

# Launch the executable
srun --hint=nomultithread --distribution=block:block cp2k.psmp -i  H2O-128.inp
