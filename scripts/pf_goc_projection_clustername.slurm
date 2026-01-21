#!/usr/bin/bash
# Script for compute the parallel fiber-Golgi cell connectivity in the SLURM system
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
#SBATCH -J GL_PYCABNN
#SBATCH -n 12
#SBATCH -p compute
#SBATCH --mem-per-cpu=4G
#SBATCH --time=01:00:00
#SBATCH --input=none
#SBATCH --output=SHAREDDIR/pf_goc_projection.out.log
#SBATCH --error=SHAREDDIR/pf_goc_projection.err.log

cd SHAREDDIR/model/pycabnn
export PARAMDIR=PARAMDIREXPORT

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

## start parallel
echo "Starting IPCluster"
IDIPCLUSTER=$(sbatch start_ipcluster.sh)
IDIPCLUSTER=${IDIPCLUSTER##* }

# check if $IDIPCLUSTER.ipython exists otherwise sleep another 30 seconds
while [ ! -d $IDIPCLUSTER.ipython ]; do
    echo "Still waiting for IPCluster"
    sleep 30
done

echo "IPCluster created but waiting another 20 seconds"
sleep 20

# check again if $IDIPCLUSTER.ipython exists and tell me if it does
if [ -d $IDIPCLUSTER.ipython ]; then
    echo "IPCluster created"
else
    echo "IPCluster not created"
    exit 1
fi

echo "Running connector"
IPYTHONDIR=$IDIPCLUSTER.ipython ./run_connector.py --parallel -i .. -o .. -p $PARAMDIR  all

echo "Unpacking all the results"
IPYTHONDIR=$IDIPCLUSTER.ipython ./unpack_db.py ../AAtoGoC.h5 120 1995
IPYTHONDIR=$IDIPCLUSTER.ipython ./unpack_db.py ../PFtoGoC.h5 120 1995

echo "Shutting down IPCluster"
scancel $IDIPCLUSTER
