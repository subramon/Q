#!/bin/bash
set -e 
make -C ../lua/ clean
make -C ../lua/ 

INCS="-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ "

VG=""
VG="valgrind "
gcc -g $INCS test_split.c ../gen_src/_split_I8_I4.c -o test_split
$VG ./test_split
echo "Completed $0 in $PWD"
