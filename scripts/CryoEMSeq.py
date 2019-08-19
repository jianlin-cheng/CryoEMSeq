#!/usr/bin/env python
docstring='''
Sequence mapping to Ca trace
step1: Map sequence to Ca trace fragments
step2: Run Qprob on each Ca fragment
step3: Select best model based on Qprob score

usage: python map_seq.py <thre> <fasta_file> <Ca_trace.pdb> <out_dir>
example:
    python map_seq.py 50 FrhA.fasta FrhA.pdb FrhA
'''

import sys,os
import glob
import re
from subprocess import Popen, PIPE, STDOUT
import numpy as np

from map2trace import *
from rank_seq import *

if __name__=="__main__":

    if len(sys.argv) != 6:
        sys.stderr.write(docstring)
        sys.exit(1)

    if sys.version_info[0] < 3:
        print("Must be using Python 3!!!")
        sys.exit(1)


    thre = sys.argv[1] #50 filter fragment that has length < thre
    fasta = sys.argv[2] #/storage/htc/bdm/tianqi/CryoEM/paper_revised/TMV/TMV.fasta
    trace = sys.argv[3] #/storage/htc/bdm/tianqi/CryoEM/paper_revised/TMV/TMV.pdb
    main_folder = sys.argv[4] #/storage/htc/bdm/tianqi/CryoEM/paper_revised/TMV/frag
    cpus_num = sys.argv[5] #10

    fasta = os.path.abspath(fasta)
    trace = os.path.abspath(trace)
    main_folder = os.path.abspath(main_folder)
    script_path = os.path.dirname(os.path.realpath(__file__))
    tools_dir = os.path.dirname(script_path)+"/tools/"

    frag_dir = main_folder+"/frag/"
    if not os.path.exists(main_folder+"/result"):
        os.system("mkdir -p "+main_folder+"/result")
    else:
        if os.path.exists(main_folder+"/result/error.txt"):
            os.system("rm "+main_folder+"/result/error.txt")

    if not os.path.exists(main_folder+"/best_model"):
        os.system("mkdir -p "+main_folder+"/best_model")
    else:
        os.system("rm -rf "+main_folder+"/best_model/*")

    if not os.path.exists(fasta):
        print("Usage: python map2trace.py <thre> <fasta_file> <Ca_trace.pdb> <out_dir>")
        print("Cannot find full-length fasta file:"+fasta)
        sys.exit(1)

    if not os.path.exists(fasta):
        print("Usage: python map2trace.py <thre> <fasta_file> <Ca_trace.pdb> <out_dir>")
        print("Cannot find full-length fasta file:"+fasta)
        sys.exit(1)

    if not os.path.isdir(frag_dir):
        print("Usage: python map2trace.py <thre> <fasta_file> <Ca_trace.pdb> <out_dir>")
        print("The output folder path: doesn't exist, Creating..."+frag_dir)
        os.system("mkdir -p "+frag_dir)

    #### Step 1. Map sequence to Ca trace fragments
    seq = get_seq(fasta)
    L = len(seq)
    print(fasta+" Length:"+str(L))

    #####save L.txt to result folder#####
    len_frag = trace2frag(trace,frag_dir)
    len_frag_filt = frag_filt(len_frag,thre,frag_dir)
    f = open(main_folder+"/result/"+"L.txt","w")
    for key, value in len_frag_filt.items():
        f.write("frag"+str(key)+" length "+str(value)+"\n")
        print("frag"+str(key)+" length "+str(value))
    f.close()
    map2frag(seq,len_frag_filt,frag_dir)
    print("Step 1. Map sequence to Ca trace fragments finished......")
    print("L.txt is saved in the "+main_folder+"/result.....")
    if not os.path.exists(main_folder+"/result/L.txt"):
        print("Step 1 failed....Cannot find "+main_folder+"/result/L.txt")
        sys.exit(1)

    #### Step 2. Run Qprob on each Ca fragment
    for key, value in len_frag_filt.items():
        if not os.path.exists(main_folder+"/result/frag"+str(key)+".txt"):
            print("perl " + script_path+"/P2_run_qprob_on_fragments_parallel.pl "+frag_dir+"/frag"+str(key)+" "+tools_dir+" "+main_folder+"/result/frag"+str(key)+".txt" + " "+ str(cpus_num))
            os.system("perl " + script_path+"/P2_run_qprob_on_fragments_parallel.pl "+frag_dir+"/frag"+str(key)+" "+tools_dir+" "+main_folder+"/result/frag"+str(key)+".txt" + " "+ str(cpus_num))
            if os.path.exists(main_folder+"/result/frag"+str(key)+".txt"):
                print("Step 2 Run Qprob on each Ca fragment "+str(key)+" finished ....")
            else:
                print("Step 2 Run Qprob on each Ca fragment "+str(key)+" failed!!!")
        else:
            print("Step 2 Run Qprob on each Ca fragment "+str(key)+" finished ....")
        #####for reverse part, run qprob
        if not os.path.exists(main_folder+"/result/frag"+str(key)+"_r.txt"):
            print("perl " + script_path+"/P2_run_qprob_on_fragments_parallel.pl "+frag_dir+"/frag"+str(key)+"_r "+tools_dir+" "+main_folder+"/result/frag"+str(key)+"_r.txt" + " "+ str(cpus_num))
            os.system("perl " + script_path+"/P2_run_qprob_on_fragments_parallel.pl "+frag_dir+"/frag"+str(key)+"_r "+tools_dir+" "+main_folder+"/result/frag"+str(key)+"_r.txt" + " "+ str(cpus_num))
            if os.path.exists(main_folder+"/result/frag"+str(key)+".txt"):
                print("Step 2 Run Qprob on each Ca fragment "+str(key)+" finished ....")
            else:
                print("Step 2 Run Qprob on each Ca fragment "+str(key)+" failed!!!")
        else:
            print("Step 2 Run Qprob on each Ca fragment "+str(key)+" finished ....")

    #### step3: Select best model based on Qprob score
    result_folder = main_folder+"/result"
    frag_len = dict()
    for line in open(result_folder+"/L.txt","r"):
        if line != '\n':
            line = line.rstrip()
            arr = line.split()
            frag_len[arr[0]] = int(arr[2])

    L = sorted(frag_len.items(), key=lambda x: x[1], reverse=True)
    dict_L = dict(L)

    frag = dict()
    best = []
    smin = 0
    smax = 0
    i = 0
    for key, value in dict_L.items():
        if (os.path.getsize(result_folder+"/"+key+".txt")==0 and os.path.getsize(result_folder+"/"+key+"_r.txt")==0 ):
            continue
        with open(result_folder+"/"+key+".txt") as f1, open(result_folder+"/"+key+"_r.txt") as f2:
            for x, y in zip(f1, f2):
                x = x.rstrip()
                arr = x.split()
                seg = arr[0]
                score = float(arr[1])
                seg = re.sub("\.pdb","",seg)
                
                y = y.rstrip()
                arr_reverse = y.split()
                seg_reverse = arr_reverse[0]
                score_reverse = float(arr_reverse[1])
                seg_reverse = re.sub("\.pdb","",seg_reverse)+"_r"

                if score > score_reverse:
                    frag[seg] = score
                else:
                    frag[seg_reverse] = score_reverse
        frag_sorted = sorted(frag.items(), key=lambda x: x[1], reverse=True)
        dict_frag_sorted = dict(frag_sorted)
        max_frag = max(dict_frag_sorted, key=dict_frag_sorted.get)
        arr = re.sub('\.pdb',"",max_frag).split('_')
        smin = int(arr[1])
        smax = int(arr[1])+value-1
        while(best_overlap(smin,smax,best)):
            if i+1 > len(frag_sorted):
                break
            max_frag_next = frag_sorted[i+1]
            max_frag = max_frag_next[0]
            arr = max_frag.split('_')
            smin = int(arr[1])
            smax = int(arr[1])+value-1
            i = i+1
        if i+1 <= len(frag_sorted):
            best.append(range(smin,smax))
            print(arr[0]+":"+str(smin)+"-"+str(smax))
            if 'r' in max_frag:
                os.system("cp "+main_folder+"/frag/"+arr[0]+"_r/"+arr[0]+"_"+str(smin)+"_qprob/models/"+arr[0]+"_"+str(smin)+"_scwrl.pdb "+main_folder+"/best_model")
            else:
                os.system("cp "+main_folder+"/frag/"+arr[0]+"/"+arr[0]+"_"+str(smin)+"_qprob/models/"+arr[0]+"_"+str(smin)+"_scwrl.pdb "+main_folder+"/best_model")
        else:
            print(arr[0]+" cannot find sequence")
        i = 0
        frag = dict()

    ######Reindex best mathching model for each fragment in Ca trace#####
    reindex_pdb(main_folder+"/best_model",script_path)
    print("Step3: Select best model based on Qprob score finished...")
    sys.stdout.write('\ndone.\n')

