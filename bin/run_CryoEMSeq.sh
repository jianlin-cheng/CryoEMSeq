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


if [ $# != 4 ]; then
	echo "$0 <path of fasta sequence> <path of Ca trace> <length threshold for fragment> <output-directory>"
	exit
fi

fasta_file=$1
Ca_trace_file=$2
threshold=$3
outputdir=$4


if [[ "$outputdir" != /* ]]
then
   echo "Please provide absolute path for $outputdir"
   exit
fi

mkdir -p $outputdir/

cd $outputdir



if [ -f "$fasta_file" ]
then
	printf "Loading $fasta_file.\n\n"
else
	printf "$fasta_file not found.\n\n"
	exit
fi


if [ -f "$Ca_trace_file" ]
then
	printf "Loading $Ca_trace_file.\n\n"
else
	printf "$Ca_trace_file not found.\n\n"
	exit
fi



printf "python /data/jh7x3/CryoEMSeq/scripts/CryoEMSeq.py $threshold $fasta_file $Ca_trace_file $outputdir\n\n"

python /data/jh7x3/CryoEMSeq/scripts/CryoEMSeq.py $threshold $fasta_file $Ca_trace_file $outputdir


