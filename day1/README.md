# Introduction to CP2K day 1


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

While we will give a brief overview of all of these methods, in this course, 
we will mainly focus on using CP2K for running DFT simulations.
DFT in CP2K is based on the Quickstep method, this is the part of CP2K devoted to solving
the electronic structure problem in order to calculate the forces on  atoms.

At the core of Quickstep, a self-consistent field (SCF) calculation is performed in order to find
the ground state energy of the system. This
involves performing a number of steps where at each step the potential is calculated 
from the electronic density and then this is used to construct a new electron
density by solving the KS equations (this density is then used in the next SCF step).
The SCF converges when the required tolerance for self-consistency is met. 
The electronic state found at the end of a converged SCF calculation represents 
the best prediction of the employed method for the electronic ground state energy minimum.


### Attendee questions

TODO: Add etherpad link

* What is your experience level with CP2K?
* Have you used any other similar packages (VASP, Quantum Espresso, CASTEP, Siesta)?
* What is your research area?

### CP2K main features

TODO: edit this

#### Quickstep

Quickstep is based on the Gaussian and plane waves method (GPW) and
its augmented extension (GAPW). Central in this approach is a dual basis of 
atom centred Gaussian orbitals and plane waves (regular grids). The former
is used to represent the wave functions and e.g. the Kohn-Sham matrix, whereas the
latter is used to represent the electronic density




#### Orbital transform method

The orbital transformation (OT) method is a direct minimisation scheme that
allows for efficient wave function optimisation. It is, especially for large 
systems and large basis sets, significantly faster than diagonalisation/DIIS 
based methods, and is guaranteed to converge. Even though it scales cubically 
with system size, approx. 1000 atoms (20k-30k basis functions) can be studied 
fairly easily.

#### Hartree Fock exchange

The Hartree Fock exchange is use in hybrid XC methods where
it is combined with GGA methods in order to improve the accuracy of the XC contribution.
This is used for PBE0 and B3LYP and also double-hybrid functionals such as
B2PLYP and B2GPPLYP which use the PT2 correlation contribution additionally.
The HFX requires use of the libint library.


#### XC functionals

There are a wide range of functionals for representing the exchange-correlation
functionals each with different levels of accuracy (the XC functional contains
approximations for the exact functionals for exchange and correlation).

Available functionals flavours include LDA, GGA, and meta-GGA. Many others provided 
by (LibXC)[https://www.tddft.org/programs/libxc/].

####  Optimisation

Global and  geometry optimisation

#### Molecular dynamics

Born Orpenheimer molecule dynamics, with a range of ensembles.

#### QM/MM

Classical molecular mechanics with a quantum mechanical QM region of interest.

#### Classical forcefields FIST

Classical forcefields in the CHARMM and AMBER formats for doing classical MD.

#### The nudged elastic band method 



#### Metadynamics

Available in inbuilt in CP2K or through Plumed.


## Exercise 0: Logging on to ARCHER2 and setting up

Information about setting up an account, ssh key pair and logging on to ARCHER2 
can be found [here](https://docs.archer2.ac.uk/quick-start/quickstart-users/)

If you would like to plot or visualise during these exercises you should ssh
with the `-XY` option.

```
ssh -XY auser@login-4c.archer2.ac.uk
```

Once you have logged into ARCHER2 you will need to do some steps to set up for
the practicals and change to the right location to run jobs.

The commands below will allow you to change to your work directory (where you can run jobs),
download the materials, and go to the folder containing the files for the first exercise.

```
auser@uan02:~> cd /work/ta042/ta042/auser
auser@uan02:/work/ta042/ta042/auser> git clone https://git.ecdf.ed.ac.uk/htetlow/intro_to_cp2k.git
auser@uan02:/work/ta042/ta042/auser> cd intro_to_cp2k/cp2k-practical-files/exercise1
auser@uan02:/work/ta042/ta042/auser/cp2k-practical-files/exercise1> ls
cp2k-job-1.sh input_H2O.inp
```

* `input_H2O.inp` is the main input file
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
       &END SCF
       
       &MGRID      # Realspace multigrid information
       ..
          CUTOFF ..     # is the energy cutoff for plane-waves
          REL_CUTOFF .. 
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
cat input-H2O.inp
```

You should be able to see a lot of these options in the input and identify the
values chosen.



We have to set up calculation type as `ENERGY_FORCE` in the `&GLOBAL` section:

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
check that they are suitable for your system. One key value which should always be set for good accuracy is the energy cutoff (link). This
will be done in the second exercise.

#### Printing

The general verbosity of the output is controlled by the `PRINT_LEVEL` command in the 
GLOBAL section. However you may want to print more information about particular properties
than others. This can be done by adding a `&PRINT` section within the input file section. eg.

```
&MOTION
   &PRINT
      &TRAJECTORY
         &EACH
            MD 1
         &END EACH
         FILENAME traj.xyz
         FORMAT xyz
      &END TRAJECTORY
   &END PRINT
&END MOTION
    
```

Again this has the options `SILENT, LOW, MEDIUM, HIGH` and also allows you to specify a filename
for the output and how regularly it is written to.
TODO: The example above doesn't use any of `SILENT, LOW, MEDIUM, HIGH`

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
Note that there is usually no need to supply the basis set file directly in your
current directory as these are included automatically from the CP2K data directory path.

On ARCHER2 you can see all the available CP2K basis set and potential files in
the following directory:

```
ls /work/y07/shared/cp2k/cp2k-8.1/data
```
You can find you basis sets for each element within these files. For example, if
you wanted to find all the hydrogen basis sets within BASIS_MOLOPT you could do:

```
grep ' H ' /work/y07/shared/cp2k/cp2k-8.1/data/BASIS_MOLOPT
```



## Running CP2K

On most HPC systems (including ARCHER2) CP2K can be found as a module file. 
Typing `module avail cp2k` gives a list of the available CP2K versions.

```
module load cp2k/8.1
```

Will make the CP2K executables for version 8.1 available.

CP2K has two executables for running in parallel. `cp2k.popt` is the parallelised executable for running MPI-only 
(e.g. no OpenMP/threading). `cp2k.psmp` is the mixed mode parallelised MPI+OpenMP executable. Since version 7.1
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

#SBATCH --account=XXX
#SBATCH --partition=standard
#SBATCH --qos=standard

# Load the relevant CP2K module
# Ensure OMP_NUM_THREADS is consistent with cpus-per-task above
# Launch the executable

module load epcc-job-env
module load cp2k/8.1

export OMP_NUM_THREADS=1
export OMP_PLACES=cores

srun --hint=nomultithread --distribution=block:block cp2k.psmp -i input-H2O.inp

```


Jobs can be submitted with:
```
sbatch cp2k-job.sh
```
You can monitor the status of running jobs with:
```
squeue -u $USER
```
and deleted with:
```
scancel JOBID
```

### Output files



#### Standard output

The main output file will contain the progress of the simulation and will be updated as the run proceeds.

The beginning of the  output contains information about the settings for the run. 
This gives the important input parameters and details of how CP2K was built and run.

The report of the calculation then follows in the output file. This will depend
on the type of run that has been chosen and the output settings. Usually it
will contain some for of SCF calculation showing the energy convergence over a number 
of steps.

The line `*** SCF run converged in    10 steps ***` is printed when the SCF has
converged. This indicates that the  required tolerance for self-consistency has been met.

After this a breakdown of the energy contributions is usually printed.



#### Restart wavefunction files

Wavefunction files are binary files that contain the wavefunctions obtained from the most recent SCF steps. 
They are named with the project_name preceding `‘-RESTART.wfn’`. One is written every SCF step, 
and if a wavefuntion file of the same name already exists the older version is moved to 
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



## Exercise 1: Calculating energy/forces

### 1.1: Looking at the outputs



Run the calculation using the job script provided.

```
sbatch cp2k-job-1.sh
```

The output should be written to the slurm-XXXX.out file (it will finish very quickly). 
Open this file e.g.

```
less slurm-500382.out
```
At the end of the calculation a timing report is given indicating it has finished.

You should also see a message that the SCF has converged (this will be further
up in the output).

*How many steps does it take to converge the SCF run?*

You will note that the SCF has been split into two parts. This is because it reaches
the limit of the `MAX_SCF` steps for the inner cycle and then move onto to a second
outer SCF step.

*What is the total run time?*

This is printed at the top of the timing report e.g.

```
 -------------------------------------------------------------------------------
 -                                                                             -
 -                                T I M I N G                                  -
 -                                                                             -
 -------------------------------------------------------------------------------
 SUBROUTINE                       CALLS  ASD         SELF TIME        TOTAL TIME
                                MAXIMUM       AVERAGE  MAXIMUM  AVERAGE  MAXIMUM
 CP2K                                 1  1.0    0.234    0.236    8.816    8.816
 qs_forces                            1  2.0    0.006    0.007    5.214    5.215
 qs_energies                          1  3.0    0.010    0.011    5.032    5.032

```

Note that the wave function restart files `exercise1-RESTART.wfn` have also 
been written.

### 1.2 Changing the print level

Change the `PRINT_LEVEL` from `LOW` to `MEDIUM` and then run the calculation again.

*What is added in the output?*


### 1.3: Restarting with SCF wavefunction

Edit the input and uncomment the line:

`WFN_RESTART_FILE_NAME exercise1-RESTART.wfn`

Also change the line `SCF_GUESS ATOMIC` to `SCF_GUESS RESTART`

This sets the input file to use the previously generated SCF wave functions
as a guess for the SCF calculation. Run the calculation again.

*How many steps does it take to converge the SCF run now?*

*What is the total run time now?*

Using the restart files as a guess
for the SCF calculation will usually speed up similar subsequent calculations as
... This is useful when you want to repeat a calculation with changing some of the
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
If the grid is too coarse then the calculation may become inaccurate. Howver increasing the CUTOFF
increases the time spent converging the SCF, as the grid becomes finer, so using an arbitrarily large
CUTOFF is not ideal. Choosing the correct value for the CUTOFF is  an important step when running 
a CP2K calculation and should usually be done whenever changing the system set up or basis set.

To converge the CUTOFF you will perform a series of calculations to
find the total energy with different values for the CUTOFF in the input file and then check the convergence of the 
energy. We will use the following CUTOFF values to give a good range:- `100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200`
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
sbatch cp2k-job-2.sh
```

CP2K will run in each directory in order with an output file is produced in each.
If you like you can look at the outputs, however the script will also extract the 
total energies into `energies.out`.

Once the job completes this file should be fully populated with data from each
run. 

*How  does the CUTOFF vs. total energy change?*

*What might be a suitable CUTOFF value to use?*

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

*How does the total energy vs. CUTOFF change now?*

*Why might this converge at a lower energy?*


## CP2K code base

CP2K is written in Fortran 2008 and can be run efficiently in parallel using a combination
of multi-threading, MPI, and CUDA. It is freely available under the GPL license.

CP2K uses the dbcsr library for sparse matrix-matrix multiplication.
FFTW for FFTs

* MPI Parallelism is done over the real space grids.
* Many subroutines make use of OpenMP threading - FFTs, collocate and integrate routines
* There is GPU offloading in dbscr, collocate and integrate routines
* Additional libraries can be used for performance - ELPA, libxsmm, libgrid

### Build instructions
