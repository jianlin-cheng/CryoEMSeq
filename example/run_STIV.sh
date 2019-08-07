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

mkdir -p /data/jh7x3/CryoEMSeq/test/STIV_out

cd /data/jh7x3/CryoEMSeq/test/STIV_out

source /data/jh7x3/CryoEMSeq/tools/python3_virtualenv/bin/activate

printf "python /data/jh7x3/CryoEMSeq/scripts/CryoEMSeq.py 40 /data/jh7x3/CryoEMSeq/example/STIV/STIV.fasta /data/jh7x3/CryoEMSeq/example/STIV/STIV_Ca_Trace.pdb STIV\n\n"

python /data/jh7x3/CryoEMSeq/scripts/CryoEMSeq.py 40 /data/jh7x3/CryoEMSeq/example/STIV/STIV.fasta /data/jh7x3/CryoEMSeq/example/STIV/STIV_Ca_Trace.pdb STIV
