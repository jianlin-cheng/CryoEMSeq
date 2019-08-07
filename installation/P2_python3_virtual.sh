#!/bin/bash -e

echo " Start install python3 virtual environment (will take ~1 min)"

cd /storage/hpc/scratch/jh7x3/CryoEMSeq//tools

rm -rf python3_virtualenv

pyvenv python3_virtualenv

source /storage/hpc/scratch/jh7x3/CryoEMSeq//tools/python3_virtualenv/bin/activate

pip install --upgrade pip

pip install numpy

echo "installed" > /storage/hpc/scratch/jh7x3/CryoEMSeq//tools/python3_virtualenv/install.done

