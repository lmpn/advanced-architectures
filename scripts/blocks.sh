export VEC=no
make clean
make
<<<<<<< HEAD
for s in 400 800 1200
=======
for s in 16 32 48 96 100 200 400 800 1200
>>>>>>> 83eff19f70030bb007616d7043a110e2663e4b3a
do
    for i in 6 7 8
    do
        ./bin/dot_product $i 8 2400 time $s > "out/time/blocks_"$s"_"$i
    done
done
