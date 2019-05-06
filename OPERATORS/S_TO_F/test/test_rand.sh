#!/bin/bash
set -e 
VG=""
VG=" valgrind --leak-check=full --show-leak-kinds=all"
INCS="-I../gen_inc/ -I../../../UTILS/inc/ -I../inc/ -I../../../UTILS/gen_inc/"
rm -f a.out
gcc -g $QC_FLAGS \
  ../test/test_tmpl_rand.c \
  ../test/tmpl_rand.c \
  ../../../UTILS/src/rdtsc.c \
  ../gen_src/_rand_I4.c \
    ${INCS} -DDEBUG -lm
$VG ./a.out 1>_x 2>&1
grep "0 errors from 0 contexts" _x 1>/dev/null 2>&1
#----------------
gcc -g $QC_FLAGS \
    ../test/test_rand_B1.c \
    ../../../UTILS/src/rdtsc.c \
    ../src/rand_B1.c \
    ${INCS} -DDEBUG -lm
$VG ./a.out 1>_x 2>&1
grep "0 errors from 0 contexts" _x 1>/dev/null 2>&1
echo "Successfully completed $0 in $PWD"
