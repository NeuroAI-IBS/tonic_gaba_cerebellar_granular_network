#!/usr/bin/bash
# Script for running a simulation job in the SLURM system
#
# Written by Shyam Kumar Sudhakar, Ivan Raikov, Tom Close, Rodrigo Publio, Daqing Guo, and Sungho Hong
# Computational Neuroscience Unit, Okinawa Institute of Science and Technology, Japan
# Supervisor: Erik De Schutter
#
# Correspondence: Sungho Hong (shhong@oist.jp)
#
# September 16, 2017

## Some parameters for running a SLURM job
#SBATCH --job-name=GL_SIM
#SBATCH --partition=compute
#SBATCH --mem=448G
#SBATCH --time=12:00:00
#SBATCH --ntasks=120
#SBATCH --ntasks-per-node=10
#SBATCH --cpus-per-task=2
#SBATCH --input=none
#SBATCH --mail-user=shhong@oist.jp
#SBATCH --mail-type=BEGIN,FAIL,END
## Standard output and standard error files
#SBATCH --output=SHAREDDIR/simulation.out.log
#SBATCH --error=SHAREDDIR/simulation.err.log

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

echo "==============Starting mpirun==============="

mpirun -n 120 nrniv -mpi -python main.py

echo "==============Mpirun has ended==============="

## Copy all the output data
echo $HOME/work/new_tonic_gaba_data/output.$SLURM_JOB_ID

mkdir -p $HOME/work/new_tonic_gaba_data/output.$SLURM_JOB_ID
rsync -av *.dat $HOME/work/new_tonic_gaba_data/output.$SLURM_JOB_ID
rsync -av *.bin $HOME/work/new_tonic_gaba_data/output.$SLURM_JOB_ID
rsync -av $PARAMDIR $HOME/work/new_tonic_gaba_data/output.$SLURM_JOB_ID

# Copy the spike data to dropbox
# cd $HOME/new_tonic_gaba_data/
# ./copy_to_dbx output.$JOB_ID
