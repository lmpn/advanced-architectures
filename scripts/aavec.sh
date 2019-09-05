#!/bin/bash

#Dar nome ao processo
#PBS -N AAvec

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
export VEC=yes
make clean
make
echo -----vec------
for n in 9 10 11
do
    	for s in 30 120
	do
        	./bin/dot_product $n 8 $s time 10 > "out/time/vec_"$s"_"$n
	done
done
