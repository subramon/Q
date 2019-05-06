#!/bin/bash
set -e 
make -C ../lua/ clean
make -C ../lua/ 

INCS="-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ "

VG=""
VG="valgrind "
gcc -g $INCS test_get.c ../gen_src/_get_I4_F8.c -o test_get
$VG ./test_get
echo "Completed $0 in $PWD"
