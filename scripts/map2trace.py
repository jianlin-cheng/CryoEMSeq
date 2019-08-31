#!/usr/bin/env python
'''
Split Ca trace into fragment, and map sequence to each fragment 

'''

import os,sys
import numpy as np

aa_3to1 = {'CYS': 'C', 'ASP': 'D', 'SER': 'S', 'GLN': 'Q', 'LYS': 'K',
    'ILE': 'I', 'PRO': 'P', 'THR': 'T', 'PHE': 'F', 'ASN': 'N', 
     'GLY': 'G', 'HIS': 'H', 'LEU': 'L', 'ARG': 'R', 'TRP': 'W', 
     'ALA': 'A', 'VAL':'V', 'GLU': 'E', 'TYR': 'Y', 'MET': 'M'}

aa_1to3 = {'C':'CYS', 'D':'ASP', 'S':'SER', 'Q':'GLN', 'K':'LYS',
    'I':'ILE', 'P':'PRO', 'T':'THR', 'F':'PHE' , 'N':'ASN', 
     'G':'GLY', 'H':'HIS', 'L':'LEU', 'R':'ARG', 'W':'TRP', 
     'A':'ALA', 'V':'VAL', 'E':'GLU', 'Y':'TYR', 'M':'MET'}

def get_seq(fasta):
    for line in open(fasta, "r"):
        line = line.rstrip()
        if line.startswith(">"):
            continue
        else:
            seq = line
            break
    return seq

def trace2frag(trace,frag_dir):
    len_frag = dict()
    i = 1  #frag number
    j = 0  #atoms number in one frag
    flag = 1
    for line in open(trace,"r"):
        if flag == 1:
            f = open(frag_dir+"/frag"+str(i)+".pdb","w")
            flag = 0
            j = 0
        line = line.rstrip()
        if line.startswith("ATOM"):
            f.write(line+"\n")
            j = j+1
        if line.startswith("TER"):
            i = i+1
            flag = 1
            f.write(line+"\n")
            f.close()

            #####reverse frag
            f = open(frag_dir+"/frag"+str(i-1)+"_r.pdb","w")
            for line in reversed(open(frag_dir+"/frag"+str(i-1)+".pdb").readlines()):
                if line.startswith('\n') or line.startswith('TER') :
                    continue
                f.write(line)
            f.write('TER\n')
            f.close()
            len_frag[i-1] = j
            #print("frag"+str(i-1)+":"+str(j))
    return len_frag

def frag_filt(len_frag,max_len,thre,frag_dir):
    len_frag_filt = dict()
    L = str(max_len)
    for key, value in len_frag.items():
        if value > int(L):
            os.system("head -"+L+" "+frag_dir+"/frag"+str(key)+".pdb > "+frag_dir+"/frag"+str(key)+"_tmp.pdb")
            os.system("rm "+frag_dir+"/frag"+str(key)+".pdb")
            os.system("mv "+frag_dir+"/frag"+str(key)+"_tmp.pdb "+frag_dir+"/frag"+str(key)+".pdb")
            os.system("head -"+L+" "+frag_dir+"/frag"+str(key)+"_r.pdb > "+frag_dir+"/frag"+str(key)+"_r_tmp.pdb")
            os.system("rm "+frag_dir+"/frag"+str(key)+"_r.pdb")
            os.system("mv "+frag_dir+"/frag"+str(key)+"_r_tmp.pdb "+frag_dir+"/frag"+str(key)+"_r.pdb")
            if not os.path.isdir(frag_dir+"/frag"+str(key)):
                os.system("mkdir "+frag_dir+"/frag"+str(key))
            if not os.path.isdir(frag_dir+"/frag"+str(key)+"_r"):
                os.system("mkdir "+frag_dir+"/frag"+str(key)+"_r")
            len_frag_filt[key] = int(L)
        elif value < int(thre):
            os.system("rm "+frag_dir+"/frag"+str(key)+".pdb")
            os.system("rm "+frag_dir+"/frag"+str(key)+"_r.pdb")
        else:
            len_frag_filt[key] = value
            if not os.path.isdir(frag_dir+"/frag"+str(key)):
                os.system("mkdir "+frag_dir+"/frag"+str(key))
            if not os.path.isdir(frag_dir+"/frag"+str(key)+"_r"):
                os.system("mkdir "+frag_dir+"/frag"+str(key)+"_r")
            #else:
                #os.system("rm -rf "+frag_dir+"/frag"+str(key)+"/*")
    return len_frag_filt

def single_map(seq,frag_trace,map_pdb):
    i = 0
    f = open(map_pdb,"w")
    for line in open(frag_trace,"r"):
        if line.startswith("ATOM"):
            atom= line[0:6].rstrip()
            atom_seq=int(line[6:11].rstrip())
            atom_name= line[12:16].rstrip()
            #res_name =line[17:20].rstrip()
            res_name = aa_1to3[seq[i]] #replace with mapping sequence
            chain = line[21:22]
            res_seq= int(line[22:26].rstrip())
            x= float(line[30:38].rstrip())
            y= float(line[38:46].rstrip())
            z= float(line[46:54].rstrip())
            occ= line[54:60].rstrip()
            tmp= line[60:66].rstrip()
            ele= line[76:78].rstrip()
            line= "{:6s}{:5d} {:^4s} {:3s} {:1s}{:4d}    {:8.3f}{:8.3f}{:8.3f}{:6.2f}{:6.2f}          {:>2s}  ".format(atom,int(i+1),atom_name,res_name,chain,int(i+1),x,y,z,float(occ),float(tmp),ele)
            f.write(line+"\n")
            i = i+1
        if line.startswith("TER"):
            f.write(line+"\n")
            break
    f.close()

def map2frag(seq,len_frag_filt,frag_dir):
    L = len(seq)
    for key, value in len_frag_filt.items():
        os.chdir(frag_dir+"/frag"+str(key))
        for i in range(0,L-value+1):
            single_map(seq[i:i+value], frag_dir+"/frag"+str(key)+".pdb",frag_dir+"/frag"+str(key)+"/frag"+str(key)+"_"+str(i+1)+".pdb")
    for key, value in len_frag_filt.items():
        os.chdir(frag_dir+"/frag"+str(key)+"_r")
        for i in range(0,L-value+1):
            single_map(seq[i:i+value], frag_dir+"/frag"+str(key)+"_r.pdb",frag_dir+"/frag"+str(key)+"_r/frag"+str(key)+"_"+str(i+1)+".pdb")