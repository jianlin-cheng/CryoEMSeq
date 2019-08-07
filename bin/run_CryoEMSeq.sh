#!/bin/bash
#--------------------------------------------------------------------------------
#  SBATCH CONFIG
#--------------------------------------------------------------------------------
#SBATCH --job-name=cRN-wMSEli         # name for the job
#SBATCH -o ResNet-wMSEli16-cullpdb-T1080-%j.out
#SBATCH --partition gpu3
#SBATCH --nodes=1
#SBATCH --ntasks=1         # leave at '1' unless using a MPI code
#SBATCH --cpus-per-task=2  # cores per task
#SBATCH --mem-per-cpu=20G  # memory per core (default is 1GB/core)
#SBATCH --time 2-00:00     # days-hours:minutes
#SBATCH --qos=normal
#SBATCH --account=general-gpu  # investors will replace this with their account name
#SBATCH --gres gpu:"GeForce GTX 1080 Ti":1
#--------------------------------------------------------------------------------

#module load cuda/cuda-9.0.176
#module load cudnn/cudnn-7.1.4-cuda-9.0.176
#export GPUARRAY_FORCE_CUDA_DRIVER_LOAD=""


if [ $# != 2 ]; then
	echo "$0 <path of features> <output-directory>"
	exit
fi

path_options=$1
outputdir=$2


if [[ "$outputdir" != /* ]]
then
   echo "Please provide absolute path for $outputdir"
   exit
fi

mkdir -p $outputdir/

cd $outputdir


source /home/jh7x3/CryoEMSeq/tools/python3_virtualenv/bin/activate
export HDF5_USE_FILE_LOCKING='FALSE'


path_options ='/home/jh7x3/CryoEMSeq/data/cullpdb_dataset/data_paths.txt'
#module load R/R-3.3.1

feature_dir=/home/jh7x3/CryoEMSeq/data
output_dir=$outputdir
acclog_dir=$outputdir

if [ -f "$path_options" ]
then
	printf "$path_options found.\n\n"
else
	printf "$path_options not found.\n\n"
	exit
fi


printf "python /home/jh7x3/CryoEMSeq/architecture/ResNet_arch/scripts/train_deepResNet_2D_gen_tune_cullpdb.py 150 64 6 'nadam' 3  100 1 $feature_dir $output_dir $acclog_dir 1 'he_normal' 'weighted_MSE_limited16' 1 $path_options\n\n"
python /home/jh7x3/CryoEMSeq/architecture/ResNet_arch/scripts/train_deepResNet_2D_gen_tune_cullpdb.py 150 64 6 'nadam' 3  100 1 $feature_dir $output_dir $acclog_dir 1 'he_normal' 'weighted_MSE_limited16' 1 $path_options


# binary_crossentropy
# VarianceScaling
# lecun_normal
# he_normal
# RandomUniform

#"GeForce GTX 1080 Ti":1
#Tesla K40m
