# Day 2

## Exercise 3: Geometry Optimisation

In this exercse we will optimise the geometry of a single water molecule. 
Geometry optimisation can be used to find the minimum energy configuration for a
particular atomic system, also known as relaxing the structure. This is done by minimising 
the forces on the atoms.

The input file is similar to those in the previous exercises, we have removed all
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
sbatch --reservation=ta042_222 cp2k-job-3.sh
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
throughout the optimisation. This can be viewed in VMD (or similar) as a series of
frames which shows the trajectory of the atoms to their final relaxed position.

You can view this with vmd:

```
module load vmd
vmd exercise3-pos-1.xyz
```

TIP: In our case the structure is simple and the optimisation happens quickly. 
However if you have a system where the optimisation will not complete then it
is a good idea to visualise your structure and check it is relaxing as expected.
If your starting structure is poor (far from the minimum) it will take longer.

The standard output file (`slurm-XXXXXX.out`) will contain sections like the 
below after each geometry optimisation step which give a summary. When optimisation
is finished you should see that the convergence check parameters are all `YES`.

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

To track the energy at over the course of the calculation you can run:

```
grep 'Total Energy' slurm-XXXX.out
```

This energy should be going downwards (we are minimising it).



## Exercise 4: Molecular dynamics

Submit this one now! It will take ~4 minutes

To run a MD calculation the run type should be set to MD. The MD settings are 
given in the `MOTION` section.

```
&MOTION
  &MD
    ENSEMBLE NVE
    STEPS 100
    TIMESTEP 0.5
    TEMPERATURE 300.0
  &END MD
&END MOTION
```

Most of these settings are self explanitory. It is worth noting that the units
for the timestep is in femtoseconds (temperature is in Kelvin).

The ENSEMBLE sets the thermostat for the system, the different options can be 
found [here](https://manual.cp2k.org/trunk/CP2K_INPUT/MOTION/MD.html#ENSEMBLE).
Here we have chosen an NVE ensemble. Doing an NVE run and checking the energy 
conservation is a good way to check the system for techincal errors.

TIP: If you have poor energy conservation either reduce `EPS_SCF` and `EPS_DEFAULT`,
increase the cutoff, or reduce the timestep. 

We have also added the following to the QS section:

```
EXTRAPOLATION_ORDER 3
EXTRAPOLATION ASPC
```

These set how the wave function is extrapolated between MD steps. The 
always stable predictor corrector method is used, which prioritises stability.
The extrapolation order is a paramter used for ASPC method, higher order may be
more accurate, but less stable.

As before, to run the simulation on the compute nodes, run:

```
sbatch --reservation=ta042_222 cp2k-job-4.sh 
```

As the simulation runs the usual output files are produced. In addition to those 
we have seen before the `exercise4-1.ener` file is produced. This contains the 
important information (such as energies) over the course of the simulation.

```
#     Step Nr.          Time[fs]        Kin.[a.u.]          Temp[K]            Pot.[a.u.]        Cons Qty[a.u.]        UsedTime[s]
         0            0.000000         0.135381356       300.000000000      -551.449021450      -551.313640094         0.000000000
         1            0.500000         0.131340447       291.045498020      -551.444804490      -551.313464043         8.637100721
         2            1.000000         0.129802132       287.636650047      -551.443130746      -551.313328614         1.908887810
         3            1.500000         0.132532972       293.688088539      -551.445907131      -551.313374159         1.859717403
         4            2.000000         0.138692431       307.337218462      -551.452296410      -551.313603979         1.617252311
         5            2.500000         0.144844864       320.970778898      -551.458707366      -551.313862502         1.690137245
```

This can be easily plotted to see the trajectory using a program of your choice. 
The Cons Qty is the conserved quantity (in this case total energy = KE + PE) 
which will depend on the thermostat used.

`exercise4-pos-1.xyz` contains the trajectory of the atomic coordinates throughout
the simulation. 

`exercise4-1.restart` is a restart file that can be used to restart from the last
step of the run. To do this edit the `cp2k-job-4.sh`

```
srun --hint=nomultithread --distribution=block:block cp2k.psmp -i exercise4-1.restart
```

This will continue the simulation for a further 100 MD steps.

### 4.2 Checkpointing and writing files

By default the atomic coordinates are written every step and the restart history information
is checkpointed every 500 steps (as well as the last 4 steps). However we may
want to change this particularly when running for many steps this amount of 
printing can mean many files (this is especially bad if your system is large as
a large amount of data will be produced).

We are going to set the input so that it writes a restart file every 50 steps.
Add the following into the `&MOTION` section of the input file and run it again.
(Please make sure to change the input file name in cp2k-job-4.sh as well or you 
will run the restart again)

```
  &PRINT
    &RESTART_HISTORY
      &EACH
        MD 50
      &END EACH
    &END RESTART_HISTORY
  &END PRINT
```

You can add a similar block to print the [velocities](https://manual.cp2k.org/cp2k-8_2-branch/CP2K_INPUT/MOTION/PRINT/VELOCITIES.html)



## Execise 5: Parallel performance on ARCHER2

### 5.1:  Scaling

We are now going to look at the performance of some MD simulations on ARCHER2. 
The system will be similar to the one in the past exercise only with slightly different
parameters. First we will run simulations across mutliple nodes and then use the 
performance results to determine the optimum number of nodes
to run on, and see how this depends on the size of the system.

In the exercise5 directory you have 3 different input files. 

```
H2O-128.inp  H2O-256.inp  H2O-32.inp 
```

These are part of the CP2K benchmark suite and be found 
[here](https://github.com/cp2k/cp2k/tree/master/benchmarks/QS/).
The number in the file name gives the number of water molecules.

Together we are going to investigate the performance of each of these systems 
aim to fill in this table (which can also be found in the etherpad).

System   |  Nodes  |  Run time (s) |
---------|---------|---------------|
H2O-32   |    1    |               |
H2O-32   |    2    |               |
H2O-32   |    4    |               |
H2O-128  |    1    |               |
H2O-128  |    2    |               |
H2O-128  |    4    |               |
H2O-256  |    1    |               |
H2O-256  |    2    |               |
H2O-256  |    4    |               |

To do list you will just need to edit the provided job script to select the 
input file and also change the `#SBATCH nodes=` parameter at the top.
On ARCHER2 there are 128 cores per node.

The run time can be easily found once the run completes 
using the following `grep` command

```
grep 'CP2K   ' slurm-XXXX.out
```


In an ideal case we might expect that if we go from using 1 to 2 nodes (or 2 to 4)
that the run time would half. However there are non parallelisable overheads
within the code which means we cannot achieve perfect scaling.

One way of seeing the scaling is to calculate the speed up:

```
Speed up = Time_1/Time_n
```



Usually we want to select the number of nodes that we run on carefully as to not 
be inefficient with the resources. For example there is usually no use running a small 
system with a small amount of computational work to be done
on many many nodes as there will be limited improvement in the performance
due to the dominance of the serial overheads at this scale. Ideally when using a new
system or new set up you should perform scaling tests to determine the optimum 
number of nodes to use.

**For the above systems how many nodes would you choose to use?**

### 5.2 Hybrid MPI+OpenMP

So far we have been running using MPI only. This means that we use as many processes
as there are cores. However with CP2K it is also possible to use a mixture 
of processes and threads, i.e. using mutliple threads per process. Threads can
share memory, and so this can help to reduce the overall memory requirements
for a calculation. It can also improve the performance compared to using MPI
only. We are going to investigate how using multiple threads affects the 
performance of the MD run - `H2O-128.inp`.

When using MPI+OpenMP one should take care to ensure that the shared memory portion
of the process/thread placement does not span more than one NUMA region.
Nodes on ARCHER2 are made up of two sockets each containing 4 NUMA regions of 16
cores, i.e. there are 8 NUMA regions in total. Therefore the total number of 
threads should ideally not be greater than 16, and also needs to be a factor of 16.
Sensible choices for the number of threads are therefore 1 (single-threaded), 2,
4, 8, and 16.

To use more than one thread you will need to edit the job script. The number of
cpus-per-process should be set to the number of threads. The tasks-per-node then
needs to be set to ensure that the whole node is used. For example
for 4 threads on a full ARCHER2 node there are 128/4 = 32 tasks.

Aim to fill in the following table.

| Threads |  Run time (s) |
|---------|---------------|
|    1    |               |
|    2    |               |
|    4    |               |
|    8    |               |
|    16   |               |

**How is the run time affected by the number of threads used?**


## Resources

CP2K has a wide variety of features that can be hard to find documentation and
appropirate resources for. Below is a list of resources where you can go to
get help in the future.


### How to guides on the website

There are a selection of how to guides on the CP2K website 
[here](https://www.cp2k.org/howto)
These cover common set up scenerios and  the basics such as force/energy
calculations, geometry optimisation etc.

### Exercises on the website

There are a number of tutorials on the CP2K website that cover some more 
advanced topics, however it is fairly tricky to find what you might need.
Here are some links to particilar exericses:

* MD of water (with GLE thermostat) - https://www.cp2k.org/exercises:2016_summer_school:aimd
* Hybrid functionals and ADMM (PBE0) - https://www.cp2k.org/exercises:2017_uzh_cp2k-tutorial:hybrid 
* Nudged elastic band method - https://www.cp2k.org/exercises:2016_uzh_cmest:path_optimization_neb
* QM/MM - https://www.cp2k.org/exercises:2016_summer_school:qmmm
* NEB and metadynamics - https://www.cp2k.org/exercises:2015_cecam_tutorial:neb


### Regression tests

The regression tests are part of the CP2K source code and can be found 
[here](https://github.com/cp2k/cp2k/tree/support/v8.1/tests).

These cover inputs to test nearly all the functionality in the code and these
may be used as a way to see input set ups for more niche options. Be wary of 
the paramters set here as they may not be to a production standard.

### CP2K Google group

This is a place to ask questions. However you may have some luck searching 
previously answered questions first.

https://groups.google.com/g/cp2k

Please read the [guidelines](https://www.cp2k.org/howto:gethelp) first.

### Bioexcel biomolecular QM/MM resources

The bioexcel QM/MM [BPG](https://docs.bioexcel.eu/qmmm_bpg/en/main/index.html) 
was written as a guide for doing QM/MM simulations with CP2K.

There are also some previous courses on using QM/MM with CP2K

[Preparing to run biomolecular QM/MM simulations with CP2K using AmberTools Online](https://www.archer2.ac.uk/training/courses/200609-amber/)


[Practical introduction to QM/MM using CP2K for biomolecular modelling](https://www.archer2.ac.uk/training/courses/201013-cp2k/)


