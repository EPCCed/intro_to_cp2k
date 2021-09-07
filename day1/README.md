# Indroduction to CP2K day 1

## About this course

This course is designed to teach attendees how to run basic CP2K calculations and give them the key knowledge
required for doing so. It will cover the important  
options in the CP2K input file and how to set up a CP2K calulcation before gooing through some practical examples.

We will also cover a selection of helpful tips and how to deal with comman problems encountered when using CP2K.
and where to find guidance and
help preparing input files

This course will assume no prior experiance of using CP2K or other atomistic simulation packages
however it will also  aim to be useful to those who have some experiance of using CP2K.

While we will be referencing denisty functional theory and other theoretical methods understanding of these is not the principal aim of this course.
Our aim is to use these systems to help familiarise attendees with using CP2K to run simulations. 

* What can CP2K do
* Understanding the input file
* Input file preparation
* Running CP2K jobs and understanding the outputs
* Key parameters and ensuring accuracy
* Getting good performance
* Common pitfalls and problems
* How to start with your own simulations and where to find guidence
* Practicals: Energy miniminisation, geometry optimiation, molecular dynamics

## About CP2K

CP2K is a quantum chemistry and solid state physics software package that can perform
atomistic simulations of a wide variety of systems, ranging from solid state to biological systems.
CP2K provides a general framework for running density functional theory (DFT) simulations, with
extensions that enable users to run classical molecular dynamics (MD), mix MD and DFT to obtain
quantum-mechanical/molecular-dynamics (QM/MM) runs, or perform other forms of metadynamics, Monte Carlo, or other simulations.

** Key links **

* https://www.cp2k.org - The CP2K website
* https://manual.cp2k.org -  The CP2K manunal
* https://github.com/cp2k/cp2k -  The CP2K github page
* https://docs.archer2.ac.uk/research-software/cp2k/cp2k/ - CP2K on ARCHER2


### Attendee questions

TODO: Add etherpad link

* What is your experiance level with CP2K?
* Have you used any other similar packages (VASP, Quantum Espresso, CASTEP, Siesta)?
* What is your research area?

### CP2K Main features

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

Born Orpenheimer 

#### QM/MM



#### Classical forcefields FIST

#### The nudged elastic band method (NEB)

#### Metadynamics

Available in CP2K inbuild or through Plumed



## Exercise 0: Logging on to ARCHER2 and setting up

Information about setting up an account, ssh key pair and logging on to ARCHER2 can be found here: https://docs.archer2.ac.uk/quick-start/quickstart-users/

Once you have logged into ARCHER2 you will need to do some steps to set for the practicals.

```
cd /work/ta0XX/ta0XX/username
wget XXXX
cd practicals/excercise0
```



## The CP2K input file

The CP2K input file contains the information about your system, the calculation details, and important parameters and required dataset files.

It is broken down into nested sections which contain parameters for different properties. 

Each section begins with the '&' symbol and must be ended with a &END statement.

Sections can contain keywords, which assign a value to that keyword, eg. METHOD below

The lower level sections and keywords must appear in the correct parent section, but the order is not important.

Indentation is usually done for readability but is not necessary to get it to run.




Some of the main sections are as follows:

```
&FORCE_EVAL
   # contains information about the system set up including DFT options, forcefield settings, atomic coordinates and kinds
   METHOD XXXX # Method used to compute forces (e.g. QS, QMMM, FIST SIRIUS..)
   &DFT

   # parameters for the DFT calculation, including MGRID, QS, SCF, XC settings
   
   
   &END DFT

   &QMMM

   &END QMMM
   
   &SUBSYS
&END FORCE_EVAL



```
Now take a look at the input file for the first exercise (a force/energy calculation of XXX).

```
cat input.inp
```

We have to set up calculation type as `ENERGY_FORCE` in the `&GLOBAL` section:

```
&GLOBAL
  PROJECT SI_0        ! Name of the calculation
  PRINT_LEVEL LOW     ! Verbosity of the output
  RUN_TYPE ENERGY_FORCE    ! Calculation type: Geometry optimisation
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

## The CP2K manual

The manual is available here:

Follows the same layout as the input file.

To be used as more of a guide as to what the parameters mean rather than instructions on how to set up your input file.

Helpful to also see the different options available.

## Input file tips

### Printing

The general verbosity of the output is controlled by the `PRINT_LEVEL` command in the 
GLOBAL section. However you may want to print more information about particular properties
than others. This can be done by adding a &PRINT section within the input file section. eg.

```
&PRINT
```

Again this has the options `SILENT, LOW, MEDIUM, HIGH` and also allows you to specify a filename
for the output and how regular it is written to.

### Units

The defult units for CP2K can be quite unfamiliar. Always check 
what the default units are if you specifying a parameter  otherwise its value may be misinterpretted.
Alternatively you can add a unit descriptor to the input file to tell CP2K what the units are.

```


```
You can check (https://manual.cp2k.org/cp2k-8_2-branch/units.html) to tell what units are valid for different physical values.

### Using varaibles

### Including files


## Running CP2K

On most HPC systems (including ARCHER2) CP2K can be found as a module file. Typing module avail cp2k
gives a list of the available CP2K versions.

module load cp2k/8.1

Will make the CP2K exectuables for version 8.1 available.

CP2K has two executables for running in parallel. cp2k.popt is the parallelised exectuable for running MPI-only 
(e.g. no OpenMP/threading). cp2k.psmp is the mixed mode parallelised MPI+OpenMP executable. Since version 7.1
cp2k.popt is just a symbolic link of cp2k.psmp with a single thread. In this tutorial we will be using cp2k.psmp.

We have provide job submission scripts for running each of the exercises on the compute nodes of ARCHER2. 
These look like this:

```
job script
```




### Basis sets, pesuedoptoentails files

In the input file above we have set it to import parameters for the basis set and pseudopotneila files. 

### Output files

## Exercise 1: Calculating energy/forces

## Example usage

Website tutorials
Regression tests

## Common pitfalls

Input file error
OOM

## Exercise 2: Converging the energy cutoff

## How to get help

