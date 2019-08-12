# CryoEMSeq
The program of mapping protein sequences into protein Ca trace drives from cryoEM image data


**(1) Download CryoEMSeq package (short path is recommended)**

```
git clone https://github.com/jianlin-cheng/CryoEMSeq.git

cd CryoEMSeq
```


**(2) Configure CryoEMSeq (required)**

```
perl setup_env.pl

cd installation
sh P1_python3_virtual.sh
```

**(4) Run CryoEMSeq (required)**

```
sh run_CryoEMSeq.sh.sh  <path of fasta sequence> <path of Ca trace> <length threshold for fragment> <output-directory> <num of cpus>

```

**(5) Practice the examples** 

```
cd example

sh run_STIV.sh

```
