#!/bin/bash
set -e
make clean
make 
# TODO ./test_mm_mul_simple 1>_x
# TODO diff _x good_output_1.txt

./test_mv_mul_simple 1>_x
diff _x good_output_2.txt

luajit test_mv_mul.lua
diff _out1.txt out1.txt 
echo "Completed $0 in $PWD"
make clean
rm -f _* test_mv_mul_simple
