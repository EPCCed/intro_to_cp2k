#!/bin/bash

#SBATCH --job-name=job2
#SBATCH --nodes=1
#SBATCH --tasks-per-node=128
#SBATCH --cpus-per-task=1
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

cutoffs="100 200 300 400 500 600 700 800 900 1000 1100 1200"

if [ -f "energies.out" ]; then
   rm energies.out
fi
 
for ii in $cutoffs ; do
    work_dir=cutoff_${ii}Ry
    cd $work_dir
    echo "Running in $work_dir"
    srun --hint=nomultithread --distribution=block:block cp2k.psmp -i input.inp > cutoff_${ii}Ry.out
    echo "$ii $(grep 'ENERGY|' cutoff_${ii}Ry.out | awk -F ' ' '{print $9}')" >> ../energies.out
    cd ..
done


