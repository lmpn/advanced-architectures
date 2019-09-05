export VEC=no
make clean
make
for s in 30 120 600 2400
do
    for i in 1 2 3 4 5
    do
        ./bin/dot_product $i 8 $s l3mr > "out/l3mr/"$i"_"$s"_l3.out"
    done
done
