#!/bin/bash

#Dar nome ao processo
#PBS -N AAblocks

#Tempo maximo do processo
#PBS -l walltime=02:00:00

#PBS -l nodes=1:r662:ppn=48

#Fila de espera para ir
#PBS -q mei
#mandar mail no principio(b) no final(e) e em caso de aborto(a)
#PBS -m bea

#para onde mandar mails
#PBS -M a77763@alunos.uminho.pt
#mandar mail no principio(b) no final(e) e em caso de aborto(a)
cd /home/a77763/AA/
source /share/apps/intel/parallel_studio_xe_2019/compilers_and_libraries_2019/linux/bin/compilervars.sh intel64
module load gcc/4.9.0
module load papi/5.5.0
export VEC=no
make clean
make
for s in 400
do
    for i in 6 7 8
    do
        ./bin/dot_product $i 8 2400 time $s > "out/time/blocks_"$s"_"$i
    done
done
