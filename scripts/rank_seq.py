#!/usr/bin/env python

docstring='''
For each fragment in the Ca trace, select the best mapping model
1. Start from Longest fragment
2. Sort based on the Qprob score, select the highest
3. Output will be stored in the best_model folder

usage: python rank_seq.py <result folder>
example:
    python rank_seq.py /storage/htc/bdm/tianqi/CryoEM/paper_revised/FrhA/result
'''

import re
import sys,os
import glob

def reindex_pdb(pdb_folder,scriptpath):
   reres = "reindex_pdb.py"
   for file in glob.glob(pdb_folder+"/*.rebuilt.scwrl.pdb"):
        frag_seg = os.path.basename(file)
        frag_seg = re.sub("\.rebuilt.scwrl.pdb","",frag_seg)
        arr = frag_seg.split('_')
        os.system("python "+scriptpath+"/"+reres+" "+arr[1]+" "+file+" "+pdb_folder+"/"+frag_seg+".pdb")
        os.system("rm -f "+file)

def range_overlap(x, y):
    if x.start == x.stop or y.start == y.stop:
        return False
    return ((x.start < y.stop  and x.stop > y.start) or
            (x.stop  > y.start and y.stop > x.start))

def best_overlap(smin,smax,best):
    x = range(smin,smax)
    flag = 0
    for y in best:
        if range_overlap(x, y):
            flag = 1

    if flag == 1:
        return True
    else:
        return False

if __name__=="__main__":
    argv=[]
    for arg in sys.argv[1:]:
        if arg.startswith("-clean="):
            clean=(arg[len("-clean="):].lower()=="true")
        elif arg.startswith('-'):
            sys.stderr.write("ERROR! Unknown option %s\n"%arg)
            exit()
        else:
            argv.append(arg)

    if len(argv)<1:
            sys.stderr.write(docstring)
            exit()

    result_folder = os.path.abspath(sys.argv[1]) #/storage/htc/bdm/tianqi/CryoEM/paper_revised/FrhA/result/result.txt

    main_folder = os.path.abspath(os.path.join(result_folder, os.pardir))
    scriptpath = os.path.dirname(os.path.realpath(__file__))

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
        for line in open(result_folder+"/"+key+".txt","r"):
            line = line.rstrip()
            arr = line.split()
            seg = arr[0]
            score = float(arr[1])
            seg = re.sub("\.rebuilt.scwrl.pdb","",seg)
            frag[seg] = score
        frag_sorted = sorted(frag.items(), key=lambda x: x[1], reverse=True)
        dict_frag_sorted = dict(frag_sorted)
        max_frag = max(dict_frag_sorted, key=dict_frag_sorted.get)
        arr = max_frag.split('_')
        smin = int(arr[1])
        smax = int(arr[1])+value-1
        while(best_overlap(smin,smax,best)):
            max_frag_next = frag_sorted[i+1]
            max_frag = max_frag_next[0]
            arr = max_frag.split('_')
            smin = int(arr[1])
            smax = int(arr[1])+value-1
            i = i+1
        best.append(range(smin,smax))
        print(arr[0]+":"+str(smin)+"-"+str(smax))
        if not os.path.exists(main_folder+"/best_model"):
            os.system("mkdir "+main_folder+"/best_model")
        os.system("cp "+main_folder+"/frag/"+arr[0]+"/"+arr[0]+"_"+str(smin)+"_qprob/models/"+arr[0]+"_"+str(smin)+".rebuilt.scwrl.pdb "+main_folder+"/best_model")
        frag = dict()

    ######Reindex best mathching model for each fragment in Ca trace#####
    reindex_pdb(main_folder+"/best_model",scriptpath)



