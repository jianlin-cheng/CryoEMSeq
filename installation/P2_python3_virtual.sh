#!/bin/bash -e

echo " Start install python3 virtual environment (will take ~1 min)"

cd /data/jh7x3/CryoEMSeq//tools

rm -rf python3_virtualenv

pyvenv python3_virtualenv

source /data/jh7x3/CryoEMSeq//tools/python3_virtualenv/bin/activate

pip install --upgrade pip

pip install numpy

echo "installed" > /data/jh7x3/CryoEMSeq//tools/python3_virtualenv/install.done

