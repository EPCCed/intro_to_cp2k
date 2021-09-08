# Indroduction to CP2K day 1

## About this course

CP2K is a quantum chemistry package for performing atomistic simulations which has a variety of applications and features.
CP2K is used for wide variety of systems such as solid state systems, molecules, liquids and biological systems.
It is optimized for the mixed Gaussian and Plane-Waves (GPW) method based on pseudopotentials, 
but is able to run all-electron or pure plane-wave/Gaussian calculations as well. 

This course is designed to teach attendees how to run basic CP2K calculations and give them the key knowledge
required for doing so. It will cover the important options in the CP2K input file and how to set up a CP2K
calculation before going through some hands-on practical exercises.

We will also cover a selection of helpful tips and how to deal with common problems encountered when using CP2K with your own system.
This will include stratergies for creating your own input file and where to find guidance and help with preparing input files.

This course will assume no prior experiance of using CP2K or other atomistic simulation packages
however it will also aim to be useful to those who have some basic experiance of using CP2K. We expect
attendees to have some understanding of the key theoretical methods used in CP2K (i.e. density functional theory and electronic structure calculations)
and experiance of using ssh, the command line and some familiarity with using HPC machines (such as ARCHER2).

While we will be referencing denisty functional theory and other theoretical methods understanding of these is not the principal aim of this course.
Our aim is to help familiarise attendees with using CP2K to run simulations. 

Topics that will be covered are:

* What can CP2K do
* Understanding the CP2K input file
* Input file preparation
* Running CP2K jobs and understanding the outputs
* Key parameters and ensuring accuracy
* Getting good performance
* Common pitfalls and problems
* How to start with running your own simulations and where to find guidence
* Practicals: Energy miniminisation, energy cut-off convergence, geometry optimiation, molecular dynamics

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


### Attendee questions

TODO: Add etherpad link

* What is your experiance level with CP2K?
* Have you used any other similar packages (VASP, Quantum Espresso, CASTEP, Siesta)?
* What is your research area?

### CP2K main features

#### Quickstep

Gaussian and Plane Waves Method

#### Obital transform method

#### GAPW


#### Hartree Fock exchange

Used in hybrid exchange correlation functionals such as B3LYP and PBE0, and double-hybrid functionals.

#### Linear scaling DFT

#### XC functionals

LDA, GGA, meta-GGA. And many others provided by LibXC.

####  Optimisation

Global and  geometry optimisation

#### Molecular dynamics

Born Orpenheimer molecule dyamics, with a range of ensembles.

#### QM/MM



#### Classical forcefields FIST

Classical forcefields in the CHARMM and AMBER formats.

#### The nudged elastic band method (NEB)

#### Metadynamics

Available in CP2K inbuild or through Plumed



## Exercise 0: Logging on to ARCHER2 and setting up

Information about setting up an account, ssh key pair and logging on to ARCHER2 can be found here: https://docs.archer2.ac.uk/quick-start/quickstart-users/

Once you have logged into ARCHER2 you will need to do some steps to set for the practicals.

```
cd /work/ta0XX/ta0XX/username
wget XXXX
cd practicals/exercise0
```



## The CP2K input file

The CP2K input file contains the information about your system, the calculation details, important parameters and any required dataset files.

The format is broken down into nested sections which contain parameters for different properties and looks something like this.

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


Some of the main sections are as follows:

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
       &SCF        # SCF parameters
       ..
       &END SCF
       
       &MGRID      # Multigrid information
       ..
       &END MGRID
       
       &QS         # Quickstep parameters
       ..
       &END QS
   
       &XC         # exchange-correlation settings
       ..
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
Now take a look at the input file for the first exercise (a force/energy calculation of XXX).

```
cat input.inp


```

We have to set up calculation type as `ENERGY_FORCE` in the `&GLOBAL` section:

```
&GLOBAL
  PROJECT Si_bulk          ! Name of the calculation
  PRINT_LEVEL LOW          ! Verbosity of the output
  RUN_TYPE ENERGY_FORCE    ! Calculation type: energy and forces
&END GLOBAL
```

In the `&FORCE_EVAL` section, we define the basic system definitions (such as 
topology and coordinates). Here we are only going to explain the most important 
ones:
- `METHOD QS` : QUICKSTEP is the QM method in CP2K ([link](https://www.cp2k.org/quickstep)).
- In the `&SUBSYS` subsection, we define several parameters of the system. 
  - `&CELL` defines the simulation box size that will contain all QM atoms.
  - `&COORD` defines the starting coordinates of the QM atoms. 
- In the `&DFT` subsection, we define several parameters of the density 
functional theory (DFT) basis set
  - `&QS` subsection where QUICKSTEP parameters are set. Amongst other things, 
we need to specify which QS method we are using (in this case `METHOD PM3`).
  - `&MGRID` subsection where parameters for calculating the Gaussian 
plane waves are defined.
  - `&SCF` subsection where parameters for finding a self-consistent solution 
(SCF) of the 
[Kohn-Sham](https://en.wikipedia.org/wiki/Kohn%E2%80%93Sham_equations) DFT 
formalism are defined.

### The CP2K manual

The CP2K manual is available [here](https://manual.cp2k.org/#gsc.tab=0)

* It follows the same layout as the input file, you can click into sections to see the sections/parameters for that section.
* It should be used as a guide as to what the input parameters mean rather than instructions on how to set up your input file.
* It can also be helpful for seeing the different settings that are available.

### Input file tips

#### Default values

A lot of parameters have default values which they are set if no value is given for them in the input file. This may seem handy but it can be
dangerous to take the default value in a lot of cases as this can lead to inaccurate results. You should question the default values and 
check that they are suitable for your system. One key value which should always be set for accuracy is the energy cutoff (link). This
will be done in the second exercise.

#### Printing

The general verbosity of the output is controlled by the `PRINT_LEVEL` command in the 
GLOBAL section. However you may want to print more information about particular properties
than others. This can be done by adding a &PRINT section within the input file section. eg.

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
for the output and how regular it is written to.

#### Units

The defult units for CP2K can be quite unfamiliar. Always check 
what the default units are if you specifying a parameter  otherwise its value may be misinterpretted.
Alternatively you can add a unit descriptor to the input file to tell CP2K what the units are.

```
CUTOFF [eV] 400

```
You can check [the manual](https://manual.cp2k.org/cp2k-8_2-branch/units.html) to see what units are valid for different physical values.

#### Using varaibles

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


## Running CP2K

On most HPC systems (including ARCHER2) CP2K can be found as a module file. Typing `module avail cp2k`
gives a list of the available CP2K versions.

```
module load cp2k/8.1
```

Will make the CP2K exectuables for version 8.1 available.

CP2K has two executables for running in parallel. `cp2k.popt` is the parallelised exectuable for running MPI-only 
(e.g. no OpenMP/threading). `cp2k.psmp` is the mixed mode parallelised MPI+OpenMP executable. Since version 7.1
`cp2k.popt` is a symbolic link of `cp2k.psmp` with a single thread. In this tutorial we will be using `cp2k.psmp`
for the practical exercises.

We have provided job submission scripts for running each of the exercises on the compute nodes of ARCHER2. 
These look like this:

```
job script
```


Jobs can be submitted with:

```
sbatch cp2k-job.sh
```

### Basis sets and pseudopotential files

In the input file for the first exercise we have defined filenames for the basis sets and pseudopotentials.

    BASIS_SET_FILE_NAME  BASIS_MOLOPT
    POTENTIAL_FILE_NAME  POTENTIAL
    &KIND H  
      ELEMENT H  
      BASIS_SET DZVP-MOLOPT-GTH
      POTENTIAL GTH-PBE
    &END KIND

The `BASIS_SET` and `POTENTIAL` options will correspond to one of the basis sets and potenials for the particular element within the basis set and potential files. 
Note that there is usually no need to supply the basis set file directly in your current directory as these are 
included automatically from the CP2K data directory path.

On ARCHER2 you can see all the available CP2K basis set and potential files in the following directory:

```
ls /work/y07/shared/cp2k/cp2k-8.1/data
```
You can find you basis sets for each element within these files. For example, if you wanted to find all the hydrogen basis sets within BASIS_MOLOPT you could do:

```
grep ' H ' /work/y07/shared/cp2k/cp2k-8.1/data/BASIS_MOLOPT
```

### Output files

#### Standard output

The main output file will contain the progress of the simulation and will be updated as the run proceeds.

The beginning of the  output contains information about the settings for the run. 
This gives the important input parameters and details of how CP2K was built and run e.g. the number of
processes and threads that were specifed when running. 

The report of the calculation then follows in the output file. For the exercise



#### Restart wavefunction files

Wavefunction files are binary files that contain the wavefunctions obtained from the most recent SCF steps. 
They are named with the project_name preceeding `‘-RESTART.wfn’`. One is written every SCF step, 
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
guide for the first SCF step to speed up the calculation. In this case  the SCF_GUESS should be set to ‘restart’
and the restart file name should be given in the SCF section, or the project names should be the same. Care should 
be taken that the wavefunction is a suitable guess for the SCF calculation otherwise 
it may not converge or take longer to.

## Exercise 1: Calculating energy/forces

Run the calculation using the job script provided.


Change the `PRINT_LEVEL` to `HIGH` and run again
What is added in the output

Restarting SCF

## Example usage

Website tutorials
Regression tests

## Common pitfalls

Input file error
OOM

## Exercise 2: Converging the energy cutoff

## How to get help

