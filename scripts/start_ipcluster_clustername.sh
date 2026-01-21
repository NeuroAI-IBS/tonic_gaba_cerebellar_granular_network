#!/usr/bin/bash
#
# Example parallel job launcher script
# Usage:
#   ./start_ipcluster_clustername.sh
#
# Originally written by Shyam Kumar Sudhakar, Ivan Raikov, Tom Close, Rodrigo Publio, Daqing Guo, and Sungho Hong
# Computational Neuroscience Unit, Okinawa Institute of Science and Technology, Japan
# Supervisor: Erik De Schutter
#
# September 16, 2017
#
# -------------------------------------------------------------
#
# Revised by Sungho Hong
# Center for Memory and Glioscience, Institute for Basic Science, South Korea
#
# Correspondence: Sungho Hong (sunghohong@ibs.re.kr)
#
# January 21, 2026

#SBATCH --job-name=GL_ipcluster
#SBATCH --partition=compute
#SBATCH --mem-per-cpu=8g
#SBATCH --ntasks=81
#SBATCH --mail-type=FAIL
#SBATCH --output=%j.out.log
#SBATCH --error=%j.err.log

# example module load commadns
module load gcc/11.2.1
module load openmpi.gcc/5.0.3
module load python/3.10.2

export PATH=$HOME/.local/bin:$PATH

NEURONHOME= # here set the path to the NEURON installation
export PATH=$NEURONHOME/x86_64/bin:$PATH
export LD_LIBRARY_PATH=$NEURONHOME/x86_64/lib:$LD_LIBRARY_PATH

# set python env vars
export PYTHONPATH=`pwd`/model:$NEURONHOME/lib/python/:$PYTHONPATH
echo PYTHONPATH is $PYTHONPATH
