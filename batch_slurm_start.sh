#!/usr/bin/bash
#
# Example job submission script for the SLURM system
#
# Usage:
#   ./batch_slurm_start.sh <name of the parameter directory under params/>
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

CLUSTER=clustername

## Copy all the model files first to a temporary directory where the simulation will run
TIMESTAMP=`date +%a%d%b%Y_%H%M`
tmpSharedDir=$HOME/work/tmp/Granular_Layer.${TIMESTAMP}
echo "Creating $tmpSharedDir"
mkdir -p ${tmpSharedDir}

mkdir ${tmpSharedDir}/model
echo cp -PR *.hoc *.ses *.py *.slurm scripts populations templates mechanisms params pycabnn ${tmpSharedDir}/model
cp -PR *.hoc *.ses *.py *.sh scripts populations templates mechanisms params pycabnn ${tmpSharedDir}/model

## Check if the parameter directory is given
TESTSETDIR=${tmpSharedDir}/model/params/
export PARAMDIR=${TESTSETDIR}"/"$1
echo "Parameter directory: $PARAMDIR"
ls $PARAMDIR

if test "${PARAMDIR}" = ""; then
   echo "You must set PARAMDIR environment variable to point to a directory containing Parameters.hoc"
   exit 1
fi

## Compile *.mod files
src_dir=$PWD
echo $PWD

cd $src_dir

## Change simulation scripts accordingly and copy them to a temporary directory
sed s#SHAREDDIR#${tmpSharedDir}#g scripts/population_init_${CLUSTER}.slurm > temp
sed s#PARAMDIREXPORT#${PARAMDIR}#g temp > ${tmpSharedDir}/population_init.slurm

sed s#SHAREDDIR#${tmpSharedDir}#g scripts/pf_goc_projection_${CLUSTER}.slurm > temp
sed s#PARAMDIREXPORT#${PARAMDIR}#g temp > ${tmpSharedDir}/pf_goc_projection.slurm

sed s#SHAREDDIR#${tmpSharedDir}#g scripts/simulation_job_${CLUSTER}.slurm > temp
sed s#PARAMDIREXPORT#${PARAMDIR}#g temp > ${tmpSharedDir}/simulation_job.slurm

cp scripts/start_ipcluster_${CLUSTER}.sh ${tmpSharedDir}/model/pycabnn/start_ipcluster.sh
cat pycabnn/_start_ipcluster.sh >> ${tmpSharedDir}/model/pycabnn/start_ipcluster.sh
rm temp

## Now working in the temp work directory
cd ${tmpSharedDir}/model

# example module load commadns
module load gcc/11.2.1
module load openmpi.gcc/5.0.3
module load python/3.10.2

# Set NEURONHOME path
NEURONHOME= # here set the path to the NEURON installation
export PATH=$NEURONHOME/x86_64/bin:$PATH

# set python env vars
export PYTHONPATH=`pwd`/model:$NEURONHOME/lib/python/:$PYTHONPATH
echo PYTHONPATH is $PYTHONPATH

nrniv -python main.py --build --verbose

echo "Setup finished, starting the parallel jobs..."

## Run everything
cd $tmpSharedDir
IDPOP=$(sbatch population_init.slurm)
IDPF=$(sbatch --dependency=afterok:${IDPOP##* } pf_goc_projection.slurm)
IDSIM=$(sbatch --dependency=afterok:${IDPF##* } simulation_job.slurm)
