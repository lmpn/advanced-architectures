export VEC=yes
make clean
make
echo -----vec------
for n in 9 10 11
do
    	for s in 30 120
	do
        	./bin/dot_product $n 8 $s time 15
	done
done
