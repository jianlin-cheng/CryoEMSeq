#!/bin/bash
#--------------------------------------------------------------------------------
#  SBATCH CONFIG
#--------------------------------------------------------------------------------
#SBATCH -J  CryoEMSeq
#SBATCH -o CryoEMSeq-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=2G
#SBATCH --time 2-00:00
#--------------------------------------------------------------------------------

module load python/python-3.5.2


if [ $# != 5 ]; then
	echo "$0 <path of fasta sequence> <path of Ca trace> <length threshold for fragment> <output-directory> <number of cpus>"
	exit
fi

fasta_file=$1
Ca_trace_file=$2
threshold=$3
outputdir=$4
cpu_num=$5

source /data/jh7x3/CryoEMSeq/tools/python3_virtualenv/bin/activate

printf "python /data/jh7x3/CryoEMSeq/scripts/CryoEMSeq.py $threshold $fasta_file $Ca_trace_file $outputdir\n\n"

python /data/jh7x3/CryoEMSeq/scripts/CryoEMSeq.py $threshold $fasta_file $Ca_trace_file $outputdir $cpu_num


