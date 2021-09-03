# Indroduction to CP2K day 1

## About this course

This course is designed to teach attendees how to run basic CP2K calculations and give them the key knowledge
required for doing so. It will cover the important  
options in the CP2K input file, before undergoing practical sessions on running 
CP2K simulations. 

We will also cover a selection of helpful tips and tricks, and where to find guidance and
help preparing input files

This course will assume no prior experiance of using CP2K or other atomistic simulation packages
however it also aim to be useful to a user with basic experienace.

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


### Questions

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


#### Linear scaling DFT

#### XC functional

#### Geometry optimisation

#### MD

#### QM/MM

#### FIST

#### NEB

#### Metadynamics




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

### The Global section

### Printing

### Units


Now take a look at the input file for the first exercise (a force/energy calculation of XXX).

```
cat input.inp
```

## The CP2K manual

The manual is available here:

Follows the same layout as the input file.

To be used as more of a guide as to what the parameters mean rather than instructions on how to set up your input file.

Helpful to also see the different options available.



## Running CP2K

### Basis sets, pesuedoptoentails files

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

