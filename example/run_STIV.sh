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

outputdir=/storage/hpc/data/wuti/test/CryoEMSeq/test/STIV_out

source /storage/hpc/data/wuti/test/CryoEMSeq/tools/python3_virtualenv/bin/activate

printf "python /storage/hpc/data/wuti/test/CryoEMSeq/scripts/CryoEMSeq.py 40 /storage/hpc/data/wuti/test/CryoEMSeq/example/STIV/STIV.fasta /storage/hpc/data/wuti/test/CryoEMSeq/example/STIV/STIV_Ca_Trace.pdb STIV\n\n"

python /storage/hpc/data/wuti/test/CryoEMSeq/scripts/CryoEMSeq.py 40 /storage/hpc/data/wuti/test/CryoEMSeq/example/STIV/STIV.fasta /storage/hpc/data/wuti/test/CryoEMSeq/example/STIV/STIV_Ca_Trace.pdb STIV







