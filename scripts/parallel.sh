export OMP_PROC_BIND=true
export VEC=yes
make clean
make
export OMP_NUM_THREADS=24
for n in 12 13 14
do
	for b in 16 32 48 96 100 200 400 800 1200
	do
        ./bin/dot_product $n 8 2400 time $b 24 > "out/time/parallel_"$n"_"$b
	done
done

