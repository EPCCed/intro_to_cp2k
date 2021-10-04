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


export OMP_NUM_THREADS=1
export OMP_PLACES=cores

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


