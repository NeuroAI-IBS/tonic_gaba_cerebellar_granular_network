#!/usr/bin/bash
# Script for initializing cell populations in the SLURM system
#
# Written by Shyam Kumar Sudhakar, Ivan Raikov, Tom Close, Rodrigo Publio, Daqing Guo, and Sungho Hong
# Computational Neuroscience Unit, Okinawa Institute of Science and Technology, Japan
# Supervisor: Erik De Schutter
#
# Correspondence: Sungho Hong (shhong@oist.jp)
#
# September 16, 2017
# -------------------------------------------------------------
#
# Revised by Sungho Hong
# Center for Memory and Glioscience, Institute for Basic Science, South Korea
#
# Correspondence: Sungho Hong (sunghohong@ibs.re.kr)
#
# January 21, 2026

## Some parameters for running a SLURM job
#SBATCH --job-name=GL_POP
#SBATCH --tasks=10
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=20G
#SBATCH --partition=compute
#SBATCH --error=SHAREDDIR/population_init.err.log
#SBATCH --output=SHAREDDIR/population_init.out.log


echo "==============Starting population init==============="
cd SHAREDDIR/model
export PARAMDIR=PARAMDIREXPORT

# example module load commadns
module load gcc/11.2.1
module load openmpi.gcc/5.0.3
module load python/3.10.2

NEURONHOME= # here set the path to the NEURON installation
export PATH=$NEURONHOME/x86_64/bin:$PATH
export LD_LIBRARY_PATH=$NEURONHOME/x86_64/lib:$LD_LIBRARY_PATH

# set python env vars
export PYTHONPATH=`pwd`/model:$NEURONHOME/lib/python/:$PYTHONPATH
echo PYTHONPATH is $PYTHONPATH

NBSUBDIV=1000000000

## Initialize cell populations first
mpirun -n 10 nrniv -mpi -python main.py --initpop --verbose

echo "==============Population init has ended==============="
