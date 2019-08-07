#!/bin/bash
#--------------------------------------------------------------------------------
#  SBATCH CONFIG
#--------------------------------------------------------------------------------
#SBATCH -J  STIV
#SBATCH -o STIV-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=2G
#SBATCH --time 2-00:00
#--------------------------------------------------------------------------------

module load python/python-3.5.2

outputdir=/data/jh7x3/CryoEMSeq/test/STIV_out

printf "Output directory: $outputdir\n\n"

if [[ "$outputdir" != /* ]]
then
   echo "Please provide absolute path for $outputdir"
   exit
fi

mkdir -p $outputdir/

cd $outputdir


printf "python /data/jh7x3/CryoEMSeq/scripts/CryoEMSeq.py 10 /data/jh7x3/CryoEMSeq/example/STIV/STIV.fasta /data/jh7x3/CryoEMSeq/example/STIV/STIV_Ca_Trace.pdb STIV\n\n"

python /data/jh7x3/CryoEMSeq/scripts/CryoEMSeq.py 10 /data/jh7x3/CryoEMSeq/example/STIV/STIV.fasta /data/jh7x3/CryoEMSeq/example/STIV/STIV_Ca_Trace.pdb STIV






