#!/usr/bin/env python

'''
For each fragment in the Ca trace, select the best mapping model
1. Start from Longest fragment
2. Sort based on the Qprob score, select the highest
3. Output will be stored in the best_model folder
'''

import re
import sys,os
import glob

def reindex_pdb(pdb_folder,scriptpath):
   reres = "reindex_pdb.py"
   for file in glob.glob(pdb_folder+"/*_scwrl.pdb"):
        frag_seg = os.path.basename(file)
        frag_seg = re.sub("\_scwrl.pdb","",frag_seg)
        arr = frag_seg.split('_')
        os.system("python "+scriptpath+"/"+reres+" "+arr[1]+" "+file+" "+pdb_folder+"/"+frag_seg+".pdb")
        os.system("rm -f "+file)

def range_overlap(x, y):
    if x.start == x.stop or y.start == y.stop:
        return False
    return ((x.start < y.stop  and x.stop > y.start) or
            (x.stop  > y.start and y.stop > x.start) or (x.stop==y.start) or (x.start == y.stop))

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
