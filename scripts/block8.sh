export VEC=no
make clean
make
for s in 16 32 48 96 100 200 400 800 1200
do
    ./bin/dot_product 8 8 2400 time $s > "out/time/blocks_"$s"_8"
done