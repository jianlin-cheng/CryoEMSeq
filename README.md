# CryoEMSeq
The program of mapping protein sequences into protein Ca trace drives from cryoEM image data

**The program requires python3 or later version!!!**

**(1) Download CryoEMSeq package (short path is recommended)**

```
git clone https://github.com/jianlin-cheng/CryoEMSeq.git

cd CryoEMSeq
```


**(2) Configure CryoEMSeq (required)**

```
perl setup_env.pl

```

**(3) Run CryoEMSeq (required)**

```
sh run_CryoEMSeq.sh  <path of fasta sequence> <path of Ca trace> <length threshold for fragment> <output-directory> <num of cpus>

```

**(4) Practice the examples** 

```
cd example

sh run_STIV.sh

```
