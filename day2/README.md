# Day 2

## Exercise 3: Geometry Optimisation

In this exercse we will optimise the geometry of a single water molecule. 
Geomtrey optimisation can be used to find the minimum energy configuration for a
particuler atomic system also known as relaxing the structure. This is done by minimising 
the forces on the atoms.

The input file is similar to those in the previuos exercises, we have removed all
but one of the water molecules. To do the geometry optimisation the `RUN_TYPE` is 
changed to `GEO_OPT` and the `MOTION` section with `GEO_OPT` settings is added.

```
&GLOBAL
  PRINT_LEVEL LOW
  PROJECT exercise3
  RUN_TYPE GEO_OPT
&END GLOBAL
```


```
&MOTION
  &GEO_OPT
     TYPE MINIMIZATION        # find the minimum (could also be transition state)
     MAX_DR    1.0E-03        # tolerance on the max displacements
     MAX_FORCE 1.0E-03        # tolerance on the max atomic forces
     RMS_DR    1.0E-03        # tolerance on the root-mean-square displacements
     RMS_FORCE 1.0E-03        # tolerance on the root-mean-square forces
     MAX_ITER 200             # max no. of geo opt iteration
     OPTIMIZER CG             # use conjugate gradient algorithm for optimiser
     &CG                      # CG section
       MAX_STEEP_STEPS  0     # do not use steepest descent steps
       RESTART_LIMIT 9.0E-01  # reset CG algorithm if cosine between searching directions is < 0.9
    &END CG
  &END GEO_OPT
&END MOTION
```

The four tolerance criteria must be met before the geometry is considered to be 
optimised. Decreasing these values means that the optimisation will be more
strict and take longer to achieve.

To run the calculation submit the job script. This will take about 2.5 minutes
to finish.

```
sbatch cp2k-job-3.sh
```

As the calculation runs you should see multiple files produced. In addition to
the `-RESTART.wfn` restart files from the previous execises you will also find 
additional restart files for the geometry optimisation.

```
exercise3-1.restart
exercise3-1.restart.bak-1
```

These are written every geometry optimisation step and contain the current 
atomic coordinates at that step. Unlike the wavefunction restart files the
files are human readable and look similar to a CP2K input file. You can
use one in place of an input file in the CP2K run command to start from that
point.

The `exercise3-pos-1.xyz` file contains a series of xyz's for the atomic coordinates
throughout the optimisation. This can be viewed in VMD or similar as a series of
frames which shows the trajectory of the atoms to their final relaxed position.

You can view this with vmd:

```
module load vmd
vmd exercise3-pos-1.xyz
```

TIP: In our case the structure is simple and the optimisation happens quickly. 
However if you have a system where the optimisation will not complete then it
is a good idea to visualise your structure and check it is relaxing as expected.

The standard output file

```
 *******************************************************************************
 ***                 BRENT   - NUMBER OF ENERGY EVALUATIONS :       5        ***
 *******************************************************************************

 --------  Informations at step =     1 ------------
  Optimization Method        =                   SD
  Total Energy               =       -17.2191971551
  Real energy change         =        -0.0080283498
  Decrease in energy         =                  YES
  Used time                  =                9.640

  Convergence check :
  Max. step size             =         0.0678118613
  Conv. limit for step size  =         0.0010000000
  Convergence in step size   =                   NO
  RMS step size              =         0.0396961004
  Conv. limit for RMS step   =         0.0010000000
  Convergence in RMS step    =                   NO
  Max. gradient              =         0.0819620786
  Conv. limit for gradients  =         0.0010000000
  Conv. for gradients        =                   NO
  RMS gradient               =         0.0479794366
  Conv. limit for RMS grad.  =         0.0010000000
  Conv. for gradients        =                   NO
 ---------------------------------------------------

```

To see the energy at each optimiation step you can run:

```
grep 'Total Energy' slurm-XXXX.out
```

This energy should be going downwards (we are minimising it).



## Exercise 4: Molecular dynamics

## Getting good parallel performance on ARCHER2

## Where to get information/help