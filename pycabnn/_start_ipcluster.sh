#SLURM SETTIINGS

echo 'HOME =' $HOME
echo 'PATH =' $PATH
echo 'LD_LIBRARY_PATH =' $LD_LIBRARY_PATH
echo 'DISPLAY = ' $DISPLAY
unset DISPLAY # Turn of DISPLAY just in case

cd $SLURM_SUBMIT_DIR
echo 'WORKDIR =' $SLURM_SUBMIT_DIR

NENGS=$(($SLURM_NTASKS - 1))
echo 'NENGS = ' $NENGS

IPYTHONDIR=$SLURM_SUBMIT_DIR/$SLURM_JOB_ID.ipython #Create an ipython configuration directory
echo $IPYTHONDIR
mkdir -p $IPYTHONDIR

ipython profile create --ipython-dir=$IPYTHONDIR
ipcontroller --ip='*' --ipython-dir=$IPYTHONDIR &

sleep 10

srun ipengine --ipython-dir=$IPYTHONDIR
