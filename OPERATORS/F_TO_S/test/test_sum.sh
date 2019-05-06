#!/bin/bash
set -e
INCS="-I../gen_inc/ -I../../../UTILS/inc/"
gcc $QC_FLAGS \
  ../test/sum_test.c \
  ../gen_src/_sum_I4.c \
  ${INCS} -DDEBUG
./a.out
echo "DONE"


