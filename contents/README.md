# Introduction to CP2K


## About CP2K

CP2K is a quantum chemistry and solid state physics software package that can perform
atomistic simulations of a wide variety of systems, ranging from solid state to biological systems.
CP2K provides a general framework for running density functional theory (DFT) simulations, with
extensions that enable users to run classical molecular dynamics (MD), 
quantum-mechanical/molecular-dynamics (QM/MM), and perform other forms of metadynamics, Monte Carlo, or other simulations.

**Key links**

* [The CP2K website](https://www.cp2k.org)
* [The CP2K manual](https://manual.cp2k.org)
* [The CP2K Github page](https://github.com/cp2k/cp2k)
* [CP2K ARCHER2 documentation](https://docs.archer2.ac.uk/research-software/cp2k/cp2k/) 

While we will give a brief overview of all of these methods these materials mainly focus on 
using CP2K for modelling and simulation involving DFT calculations. DFT in CP2K is based on 
the Quickstep method, this is the part of CP2K devoted to solving the electronic structure 
problem in order to calculate the forces on atoms.

At the core of Quickstep, a self-consistent field (SCF) calculation is performed in order to find
the ground state energy of the system. This
involves performing a number of steps where at each step the potential is calculated 
from the electronic density and then this is used to construct a new electron
density by solving the Kohn-Sham equations (this density is then used in the next SCF step).
The SCF converges when the required tolerance for self-consistency is met. 
The electronic state found at the end of a converged SCF calculation represents 
the best prediction of the employed method for the electronic ground state energy minimum.


### CP2K main features


#### Quickstep

Quickstep is based on the Gaussian and plane waves method (GPW) and
its augmented extension (GAPW). Central in this approach is a dual basis of 
atom centred Gaussian orbitals and plane waves (regular grids). The former
is used to represent the wave functions and e.g. the Kohn-Sham matrix, whereas the
latter is used to represent the electronic density


#### Orbital Transformation method

The Orbital Transformation (OT) method is a direct minimisation scheme that
allows for efficient wave function optimisation. It is, especially for large 
systems and large basis sets, significantly faster than diagonalisation/DIIS 
based methods, and is guaranteed to converge. Even though it scales cubically 
with system size, approx. 1000 atoms (20k-30k basis functions) can be studied 
fairly easily.


#### XC functionals

There are a wide range of functionals for representing the exchange-correlation
functional each with different levels of accuracy (the XC functional contains
approximations for the exact functionals for exchange and correlation).

Available functionals flavours include LDA, GGA, and meta-GGA. Many others provided 
by [LibXC](https://www.tddft.org/programs/libxc/).

#### Hartree Fock exchange (HFX)

The Hartree Fock exchange for use in hybrid XC methods.
This can be used for PBE0 and B3LYP and also double-hybrid functionals such as
B2PLYP and B2GPPLYP which use the PT2 correlation contribution additionally.
The HFX requires use of the [libint](https://github.com/evaleev/libint) library.

####  Optimisation

Geometry and cell optimisation.

#### Ab initio Molecular Dynamics (AIMD) 

Born Oppenheimer molecular dynamics, with a wide range of MD ensembles.

#### QM/MM

Classical molecular mechanics with a quantum mechanical QM region of interest.
QM/MM in CP2K is fully periodic.

#### Classical forcefields (FIST)

Classical forcefields in the CHARMM and AMBER formats for doing classical MD.

#### The Nudged Elastic Band (NEB) method 

For finding transition states and minimum energy pathways. Climbing-image
and improved tangent NEB are available.

#### Metadynamics

Available as inbuilt in CP2K or through [Plumed](https://www.plumed.org).


#### And many others listed [here](https://www.cp2k.org/features)

## CP2K code base

* CP2K is written in Fortran 2008 and can be run efficiently in parallel using a combination
of multi-threading, MPI, and CUDA.
* CP2K uses the DBCSR library for sparse matrix-matrix multiplication and the FFTW
library for FFTs
* MPI Parallelism is done over the real space grids.
* Many subroutines make use of OpenMP threading - FFTs, collocate and integrate routines
* There is GPU offloading in DBCSR, collocate and integrate routines
* Additional libraries can be used for performance - ELPA, libxsmm, libgrid

### Build instructions

Build instructions for CP2K on ARCHER2 (and other machines) can be found
[here](https://github.com/hpc-uk/build-instructions/tree/main/apps/CP2K)

## Exercise 0: Logging on to ARCHER2 and setting up

Information about setting up an account, ssh key pair and logging on to ARCHER2 
can be found [here](https://docs.archer2.ac.uk/quick-start/quickstart-users/)

If you would like to plot or visualise during these exercises you should include the ssh
option `-XY`:

```
ssh -XY auser@login.archer2.ac.uk
```

Once you have logged into ARCHER2 you will need to do some steps to set up for
the practicals and change to the right location to run jobs.

The commands below will allow you to change to your work directory (where you can run jobs),
download the materials, and go to the folder containing the files for the first exercise.

```
auser@ln02:~> cd /work/ta154/ta154/auser
auser@ln02:/work/ta154/ta154/auser> git clone https://github.com/epcced/intro_to_cp2k.git
auser@ln02:/work/ta154/ta154/auser> cd intro_to_cp2k/cp2k-practical-files/exercise1
auser@ln02:/work/ta154/ta154/auser/cp2k-practical-files/exercise1> ls
cp2k-job-1.sh input_H2O.inp
```

* `input_H2O.inp` is the CP2K input file
* `cp2k-job-1.sh` is the job submission script



## The CP2K input file

The CP2K input file contains the information about your system, the calculation 
details, important parameters and any required dataset files.

The format is broken down into nested sections which contain parameters for 
different properties and looks something like this.

```
! Parent section
&SECTION
  ! subsection 
  &SECTION1
    VARIABLE1 value    ! this is a variable
    ...
  &END SECTION1
  ! another subsection
  &SECTION2
    VARIABLE2 value
    ...
  &END SECTION2
&END SECTION
```

* Each section name begins with the `&` symbol and must be ended with a `&END` statement - e.g. `&SECTION, &END SECTION`
* Sections can contain keywords, which assign a value to that keyword - e.g. `VARIABLE value`
* The lower level sections and keywords must appear in the correct parent section, but the order of sections is not important.
* Indentation is usually done for readability but is not strictly necessary.
* Comments can be made with either the `!` or `#` symbols


CP2K scripts require three primary sections (`&GLOBAL`, `&FORCE_EVAL`, and 
`&MOTION`), each of which has a number of subsections. Some of the main sections are as follows:

```
&GLOBAL            # global settings for the simulation
   PROJECT      .. # the project name
   RUN_TYPE     .. # run type (e.g. MD, ENERGY, BAND, GEO_OPT..)
   PRINT_LEVEL  .. # the verbosity of the output (SILENT, LOW, MEDIUM, HIGH)
&END GLOBAL

&FORCE_EVAL        # contains information about the system set up including DFT options, forcefield settings, atomic coordinates and kinds
   METHOD XXXX     # Method used to compute forces (e.g. QS, QMMM, FIST SIRIUS..)
   &DFT            # parameters for the DFT calculation
       BASIS_SET_FILE_NAME  ..     # filename for the basis sets
       POTENTIAL_FILE_NAME  ..     # filename for the potential
       &SCF        # SCF parameters (self-consistent field calculation)
       ..
          SCF_GUESS ..  # sets the initial guess for the electron density
          EPS_SCF ..    # is the tolerance for SCF convergence
          MAX_SCF ..    # maximum number of inner SCF steps
          &OT     # Orbital transform minimiser scheme
            ..
          &END OT
          &OUTER_SCF
              EPS_SCF   # tolerance for the outer SCF (must be smaller or equal to inner EPS_SCF)
              MAX_SCF   # maximum number of outer SCF steps
          &END OUTER_SCF

       &END SCF
       
       &MGRID      # Realspace multigrid information
       ..
          CUTOFF ..     # is the energy cutoff for plane-waves
          REL_CUTOFF .. # energy cutoff for reference grid
          NGRIDS ..     # is the number of multigrids to use
       &END MGRID
       
       &QS         # Quickstep parameters
       ..
          EPS_DEFAULT ..  # sets the default threshold for energy correctness
       &END QS
   
       &XC         # exchange-correlation functional settings
       ..
          &XC_FUNCTIONAL
          ..
          &END XC_FUNCTIONAL
       &END XC
   &END DFT

   &SUBSYS 
       &CELL       # The dimensions of the simulation cell
       ..
       &END CELL
       
       &COORD      # List of atomic coordinates
       ..
       &END COORD
       
       &KIND       # Atomic kind information
           ELEMENT    ..
           BASIS_SET  ..
           POTENTIAL  ..
       &END 
&END FORCE_EVAL

&MOTION            # settings for any atomic movement (e.g. MD, NEB, optimisations, MC)
..
&END MOTION
```
Now take a look at the input file for the first exercise (a force/energy calculation of 32 water molecules).

```
cat input_H2O.inp
```

You should be able to see a lot of these options in the input and identify the
values chosen.


The type of CP2K run that we want has been defined in the `&GLOBAL` section as an `ENERGY_FORCE` calculation:

```
&GLOBAL
  PRINT_LEVEL LOW          ! Verbosity of the output
  PROJECT exercise1        ! Name of the project for the calculation
  RUN_TYPE ENERGY_FORCE    ! Calculation type: energy and forces
&END GLOBAL
```


### The CP2K manual

The CP2K manual is available [here](https://manual.cp2k.org/#gsc.tab=0)

* It follows the same layout as the input file, you can click into sections to see the sections/parameters for that section.
* It should be used as a guide as to what the input parameters mean rather than instructions on how to set up your input file.
* It can also be helpful for seeing the different settings that are available.

### Input file tips

#### Default values

A lot of parameters have default values which they are set if no value is given for them in the input file. This may seem handy but it can be
dangerous to take the default value in a lot of cases as this can lead to inaccurate results. You should question the default values and 
check that they are suitable for your system. One key value which should always 
be set for good accuracy is the energy [cutoff](https://www.cp2k.org/howto:converging_cutoff). This
will be done in the second exercise.

#### Printing

The general verbosity of the output is controlled by the `PRINT_LEVEL` command in the 
GLOBAL section. However you may want to print more information about particular properties
than others. This can be done by adding a `&PRINT` section within the input file section. eg.

```
&MOTION
   &PRINT
      &TRAJECTORY MEDIUM
         &EACH
            MD 1
         &END EACH
         FILENAME traj.xyz
         FORMAT xyz
      &END TRAJECTORY
   &END PRINT
&END MOTION
    
```

Again this has the print level options `SILENT, LOW, MEDIUM, HIGH` and also 
allows you to specify a filename for the output and how regularly it is written 
to.


#### Units

The default units for CP2K can be quite unfamiliar. In a lot of cases atomic units
are the default. Always check what the default units are if you specifying a 
parameter otherwise its value may be misinterpreted.
Alternatively you can add a unit descriptor to the input file to tell CP2K what 
the units are.

```
CUTOFF [eV] 400

```
You can check [the manual](https://manual.cp2k.org/cp2k-8_2-branch/units.html)
to see what units are valid for different physical values.

#### Using variables

Variables in the input file can be defined with:
```
@SET VAR value
```
and then used with:
```
$VAR
```
This can be useful for changing systems properties easily e.g. cell dimensions.

#### Including files

Text from files can be included with:
```
@include `filename`
```




### Basis sets and pseudopotential files

In the input file for the first exercise we have defined filenames for the basis 
sets and pseudopotentials.

```
    BASIS_SET_FILE_NAME  BASIS_MOLOPT
    POTENTIAL_FILE_NAME  GTH_POTENTIALS
``` 

```
    &KIND H  
      ELEMENT H  
      BASIS_SET DZVP-MOLOPT-SR-GTH-q1
      POTENTIAL GTH-PBE-q1
    &END KIND
```

The `BASIS_SET` and `POTENTIAL` options will correspond to one of the basis sets
and potentials for the particular element within the basis set and potential files. 
Note that there is usually no need to supply the basis set or potential files directly in the
working directory for your run as these are included automatically from the CP2K data directory path (the CP2K_DATA environment variable typically set by an environment module on HPC systems like ARCHER2). 

On ARCHER2 you can see all the available CP2K basis set and potential files in
the following directory:

```
ls /work/y07/shared/apps/core/cp2k/cp2k-2023.2/data
```
You can find you basis sets for each element within these files. For example, if
you wanted to find all the hydrogen basis sets within BASIS_MOLOPT you could do:

```
grep ' H ' /work/y07/shared/apps/core/cp2k/cp2k-2023.2/data/BASIS_MOLOPT
```


## Running CP2K

On most HPC systems (including ARCHER2) a CP2K installation can be used by loading an environment module file. Typing `module avail cp2k` gives a list of the available CP2K versions. The `module load` command will load a given installed version of CP2K, for example on ARCHER2:

```
module load cp2k/2023.2
```

CP2K has two executables for running in parallel. `cp2k.popt` is the parallelised executable for running MPI-only 
(e.g. no OpenMP threading). `cp2k.psmp` is the mixed mode parallelised MPI+OpenMP executable. Since version 7.1
`cp2k.popt` is a symbolic link of `cp2k.psmp` with a single thread. In this tutorial we will be using `cp2k.psmp`
for the practical exercises.

We have provided job submission scripts for running each of the exercises on the compute nodes of ARCHER2. 
These look like this:

```
#!/bin/bash

#SBATCH --job-name=CP2K_test
#SBATCH --nodes=1
#SBATCH --tasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --time=00:20:00

#SBATCH --account=ta154
#SBATCH --partition=standard
#SBATCH --qos=standard

# Load the relevant CP2K module
module load cp2k/2023.2

# Ensure OMP_NUM_THREADS is consistent with cpus-per-task above
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Set thread affinity as recommended
export OMP_PLACES=cores

# Ensure cpus-per-task are passed to srun
export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK

# Launch the executable
srun --hint=nomultithread --distribution=block:block cp2k.psmp -i input_H2O.inp

```

Note: by default the output from CP2K will go to stdout. For convenience you can pipe this into a named file:

```
srun --hint=nomultithread --distribution=block:block cp2k.psmp -i input_H2O.inp > namedFile.log
```

or you can use the `-o` option to tell CP2K to output to a named file:

```
srun --hint=nomultithread --distribution=block:block cp2k.psmp -i input_H2O.inp -o namedFile.log
```


## Exercise 1: Calculating energy/forces

### 1.1: Run CP2K and look at the outputs


Submit the job with the calculation using the job script provided. 
When a reservation is active, do this as follows:

```
sbatch --reservation=reservationID --qos=reservation cp2k-job-1.sh
```

When a reservation is not active, use:

```
sbatch --qos=short cp2k-job-1.sh
```

You can monitor the status of all your jobs with `squeue -u $USER`, cancel individual jobs with `scancel JOBID`, or cancel all your jobs with `scancel -u $USER`


### Output files

#### Standard output

The main output file will contain the progress of the simulation and will be updated as the run proceeds.

The beginning of the  output contains information about the settings for the run. 
This gives the important input parameters and details of how CP2K was built and run.

The report of the calculation then follows in the output file. This will depend
on the type of run that has been chosen and the output settings. Usually it
will contain some details for the SCF calculation showing the energy convergence over a number 
of steps.

The line `*** SCF run converged in    10 steps ***` is printed when the SCF has
converged. This indicates that the  required tolerance for self-consistency has been met.

After this a breakdown of the energy contributions is usually printed.

The output should be written to the slurm-XXXX.out file (it will finish very quickly), or 
to another named file if you piped the output from CP2K to another file or used the `-o` option. 

Open this file e.g.

```
less slurm-500382.out
```

At the end of the calculation a timing report is given indicating it has finished.

You should also see a message that the SCF has converged (this will be further
up in the output).

**How many steps does it take to converge the SCF run?**

You will note that the SCF has been split into two parts. This is because it reaches
the limit of the `MAX_SCF` steps for the inner cycle and then move onto to a second
outer SCF step.

**What is the total run time?**

This is printed at the top of the timing report e.g.

```
 -------------------------------------------------------------------------------
 -                                                                             -
 -                                T I M I N G                                  -
 -                                                                             -
 -------------------------------------------------------------------------------
 SUBROUTINE                       CALLS  ASD         SELF TIME        TOTAL TIME
                                MAXIMUM       AVERAGE  MAXIMUM  AVERAGE  MAXIMUM
 CP2K                                 1  1.0    0.061    0.073    5.349    5.354
 qs_forces                            1  2.0    0.014    0.018    4.978    4.984
 qs_energies                          1  3.0    0.008    0.013    4.788    4.796
```

Note that the wave function restart files `exercise1-RESTART.wfn` have also 
been written.

### 1.2 Changing the print level

Change the `PRINT_LEVEL` from `LOW` to `MEDIUM` and then run the calculation again.

**What is added in the output?**

### Restart wavefunction files

Wavefunction files are binary files that contain the wavefunctions obtained from the most recent SCF steps. 
They are named with the project_name preceding `‘-RESTART.wfn’`. One is written every SCF step, 
and if a wavefunction file of the same name already exists the older version is moved to 
`NAME-RESTART.wfn.bak-1`, rather than overwritten. This is done for up to three files and so 
you may see the following files, where the third backup (bak-3) is the oldest.

```
NAME-RESTART.wfn
NAME-RESTART.wfn.bak-1
NAME-RESTART.wfn.bak-2
NAME-RESTART.wfn.bak-3
```

Wavefunction restarts are used when restarting a calculation in order to act as a 
guide for the first SCF step to speed up the calculation. In this case  the `SCF_GUESS` should be set to ‘restart’
and the restart file name should be given in the SCF section, or the project names should be the same. Care should 
be taken that the wavefunction is a suitable guess for the SCF calculation otherwise 
it may not converge or take longer to.



### 1.3: Restarting with SCF wavefunction

Edit the input and uncomment the line:

`WFN_RESTART_FILE_NAME exercise1-RESTART.wfn`

Also change the line `SCF_GUESS ATOMIC` to `SCF_GUESS RESTART`

This sets the input file to use the previously generated SCF wave functions
as a guess for the SCF calculation. Run the calculation again.

**How many steps does it take to converge the SCF run now?**

**What is the total run time now?**

Using the restart files as a guess
for the electron density in the SCF calculation will usually speed up similar 
subsequent calculations. 
This is useful when you want to restart a calculation or repeat a calculation 
with changing some of the
settings.






## Exercise 2: Converging the energy cutoff

### 2.1 Using our previous water input

In this exercise you will converge the energy cutoff for the same system as in the previous 
exercise.

This exercise is adapted from the exercise [here](https://www.cp2k.org/events:2018_summer_school:converging_cutoff).
This version is less detailed, if you would like more information you can refer
to the original.

Quickstep uses a multi-grid system for mapping the product Gaussians onto the real space grid(s).
The energy cutoff sets the planewave cutoff in Ry. A larger cutoff translates to a finer multi-grid.
If the grid is too coarse then the calculation may become inaccurate. However increasing the `CUTOFF`
increases the time spent converging the SCF, as the grid becomes finer, so using an arbitrarily large
`CUTOFF` is not ideal. Choosing the correct value for the `CUTOFF` is  an important step when running 
a CP2K calculation and should usually be done whenever changing the system set up or basis set.

To converge the `CUTOFF` you will perform a series of calculations to
find the total energy with different values for the `CUTOFF` in the input file and then check the convergence of the 
energy. We will use the following `CUTOFF` values to give a good range:- `100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200`
For ease of use the set up of the input files will be done with a script - `gen_cutoff.sh`. All this does is create
directories for each CUTOFF value and fill them with the input file where the CUTOFF value has been correctly
set. The jobscript `cp2k-job-2.sh` that runs the CP2K jobs also extracts the energies and run times.

If you go to the exercise 2 directory you should see 4 files:

- `gen_cutoff.sh` - this is a bash script for generating input files and directories for different cutoff values
- `input_H2O_temp.inp` - this is a template for the input files where the CUTOFF can be easily changed
- `execise2-RESTART.wfn` - this is the converged SCF wavefunction which will be used as a guess for the SCF in each calculation
- `cp2k-job-2.sh` - this is a job script that will run the calculations in each directory and extract information from the outputs


Run the generation script to create and populate the directories. 
If you look at the input file in one of the directories you should see the 
cutoff value corresponds to the directory name.

```
bash gen_cutoff.sh
cat cutoff_100Ry/input.inp
```

Now submit the job script.

```
sbatch --reservation=reservationID --qos=reservation cp2k-job-2.sh
```

CP2K will run in each directory in order with an output file is produced in each.
If you like you can look at the outputs, however the script will also extract the 
total energies into `energies.out`.

Once the job completes this file should be fully populated with data from each
run. 

**How  does the CUTOFF vs. total energy change?**

**What might be a suitable CUTOFF value to use?**

You may also want to look at the difference in the `SUM OF ATOMIC FORCES` in
each output to see how this changes with the `CUTOFF`. The difference in the forces
on the atoms illustrates how important choosing the a good value for the `CUTOFF` is.

### 2.2 Changing the XC functionals (optional)

Change the XC functional from PBE to PADE. In doing this we are going from the
generalised gradient approximation (GGA) to the local density approximation (LDA).

You will need to change the functional in the XC section

```
&XC
   &XC_FUNCTIONAL PADE
   ...
```

And also change the POTENTIAL in the KIND sections for both H and O to use the corresponding
potential for the XC functional.

```
&KIND H
   BASIS_SET DZVP-MOLOPT-SR-GTH-q1
   POTENTIAL GTH-PADE-q1
&END
```

Repeat the steps as in the previous exercise.

**How does the total energy vs. CUTOFF change now?**

**Why might this converge at a lower energy?**

## Creating your own input file

Important areas to consider when setting up a CP2K calculation from scratch.


1. Your system coordinates and cell dimensions.
 * What is your system are your input coordinates correct?
 * Is your system periodic (crystalline), or a molecule, or surface and are the cell dimensions correct for this?

2. What basis sets and potentials are available for the elements in your system?
 * The files `BASIS_SETS` (or `BASIS_MOLOPT` for molecular structures) are a good place to start.
 * These range in accuracy from SZP-GTH -> DZVP-GTH -> TZVP-GTH -> TZV2P-GTH
 * Use TZVP-GTH or higher for production runs.
 * The potential e.g. `GTH-PBE-q1` should match your choice of XC functional.

3. The SCF set up.
 * The choice of optimiser/minimiser - OT or traditional diagonalisation see - [https://www.cp2k.org/events:2018\_summer\_school:scf\_setup](https://www.cp2k.org/events:2018_summer_school:scf_setup)
 * Do you need to add smearing? (For metals or large band gap materials)
 * The tolerance set in  `EPS_SCF`?
 * Are there enough steps in `MAX_SCF` for the SCF to converge?
 * Choice of `OUTER_SCF` settings to help with convergence.

4. The choice of XC functional.
 * These range in complexity/accuracy: LDA-> GGA -> metaGGA -> hybrid -> higher order methods
 * GGA is a good starting point. You should check properties before trying higher order methods.
 * Check your potentials match the XC choice.

5. Are the `CUTOFF` and `REL CUTOFF` suitable? You can do the convergence check to determine this.

6. Does the SCF converge for a single point energy calculation? Is the energy reasonable?

7. Can you calculate some known property and is the result reasonable?
e.g. a formation energy, lattice constant.



## Exercise 3: Geometry Optimisation

In this exercsie we will optimise the geometry of a single water molecule. 
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
sbatch --reservation=reservationID --qos=reservation cp2k-job-3.sh
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
sbatch --reservation=reservationID --qos=reservation cp2k-job-4.sh 
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
grep 'CP2K  ' slurm-XXXX.out
```


In an ideal case we might expect that if we go from using 1 to 2 nodes (or 2 to 4)
that the run time would half. However there are non parallelisable overheads
within the code which means we cannot achieve perfect scaling.

One way of evaluating how well the performance scales when increasing the number of cores (nodes) used in parallel is to calculate the speedup, which is the ratio of the time taken to run on 1 node (`Time_1`) versus on n nodes (`Time_n`):

```
Speedup = Time_1/Time_n
```

The parallel efficiency is then given by:

```
Parallel Efficiency = 100*(Speedup/n)
```

With 100% parallel efficiency equating to ideal scaling. 

Usually we want to select the number of nodes that we run on in parallel carefully so as to improve turnaround time for calculations but not be inefficient with compute resources. For example there is usually no use running a small system with a small amount of computational work to be done
on many many nodes as there will be limited improvement in the performance due to the dominance of the serial overheads at this scale. Ideally when using a new system or new set up you should perform scaling tests to determine the optimum number of nodes to use.

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


### "How To" guides on the CP2K website

There are a selection of how to guides on the CP2K website 
[here](https://www.cp2k.org/howto)
These cover common set up scenarios and  the basics such as force/energy
calculations, geometry optimisation etc.

### Exercises on the CP2K website

There are a number of tutorials on the CP2K website that cover some more 
advanced topics, however it is fairly tricky to find what you might need.
Here are some links to particilar exercises:

* MD of water (with GLE thermostat) - [https://www.cp2k.org/exercises:2016\_summer\_school:aimd](https://www.cp2k.org/exercises:2016_summer_school:aimd)
* Hybrid functionals and ADMM (PBE0) - [https://www.cp2k.org/exercises:2017\_uzh\_cp2k-tutorial:hybrid](https://www.cp2k.org/exercises:2017_uzh_cp2k-tutorial:hybrid)
* Nudged elastic band method - [https://www.cp2k.org/exercises:2016\_uzh\_cmest:path\_optimization\_neb](https://www.cp2k.org/exercises:2016_uzh_cmest:path_optimization_neb)
* QM/MM - [https://www.cp2k.org/exercises:2016\_summer\_school:qmmm](https://www.cp2k.org/exercises:2016_summer_school:qmmm)
* NEB and metadynamics - [https://www.cp2k.org/exercises:2015\_cecam\_tutorial:neb](https://www.cp2k.org/exercises:2015_cecam_tutorial:neb)


### Regression tests

The regression tests are part of the CP2K source code and can be found 
[here](https://github.com/cp2k/cp2k/tree/support/v2023.2/tests).

These cover inputs to test nearly all the functionality in the code and these
may be used as a way to see input set ups for more niche options. Be wary of 
the paramters set here as they may not be to a production standard.

### CP2K Google group

This is a place to ask questions. However you may have some luck searching 
previously answered questions first.

[https://groups.google.com/g/cp2k](https://groups.google.com/g/cp2k)

Please read the [guidelines](https://www.cp2k.org/howto:gethelp) first.

### BioExcel biomolecular QM/MM resources

The bioexcel QM/MM [BPG](https://docs.bioexcel.eu/qmmm_bpg/en/main/index.html) 
was written as a guide for doing QM/MM simulations with CP2K.

There are also some previous courses on using QM/MM with CP2K

[Preparing to run biomolecular QM/MM simulations with CP2K using AmberTools Online](https://www.archer2.ac.uk/training/courses/200609-amber/)


[Practical introduction to QM/MM using CP2K for biomolecular modelling](https://www.archer2.ac.uk/training/courses/201013-cp2k/)



