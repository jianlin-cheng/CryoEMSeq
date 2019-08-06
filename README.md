# CryoEMSeq
The program of mapping protein sequences into protein Ca trace drives from cryoEM image data

Prerequisites
Python3 with numpy should be installed

CryoEMSeq:Sequence mapping to Ca trace
step1: Map sequence to Ca trace fragments
step2: Run Qprob on each Ca fragment
step3: Select best model based on Qprob score

usage: python map2seq.py <thre> <fasta_file> <Ca_trace.pdb> <out_dir>
example:
    python map2seq.py 50 FrhA.fasta FrhA.pdb FrhA

thre : length of fragments >= thre in the Ca trace will be mapped sequence
fasta_file : input full length true sequence
Ca_trace.pdb : predicted Ca trace in pdb format
out_dir : output dir 

Final model will be saved in out_dir/best_model 
