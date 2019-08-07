#!/bin/bash
#--------------------------------------------------------------------------------
#  SBATCH CONFIG
#--------------------------------------------------------------------------------
#SBATCH -J  TRPV1
#SBATCH -o TRPV1-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=2G
#SBATCH --time 2-00:00
#--------------------------------------------------------------------------------

module load python/python-3.5.2

outputdir=/home/jh7x3/CryoEMSeq/test/TRPV1_out

printf "Output directory: $outputdir\n\n"

if [[ "$outputdir" != /* ]]
then
   echo "Please provide absolute path for $outputdir"
   exit
fi

mkdir -p $outputdir/

cd $outputdir


printf "python /home/jh7x3/CryoEMSeq/scripts/CryoEMSeq.py 10 /home/jh7x3/CryoEMSeq/example/TRPV1/TRPV1.fasta /home/jh7x3/CryoEMSeq/example/TRPV1/TRPV1.pdb TRPV1\n\n"

python /home/jh7x3/CryoEMSeq/scripts/CryoEMSeq.py 10 /home/jh7x3/CryoEMSeq/example/TRPV1/TRPV1.fasta /home/jh7x3/CryoEMSeq/example/TRPV1/TRPV1.pdb TRPV1






