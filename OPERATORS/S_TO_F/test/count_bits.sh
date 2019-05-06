#!/bin/bash
set -e 
INCS="-I../gen_inc/ -I../../../UTILS/inc/ -I../inc/ -I../../../UTILS/gen_inc/ "
make -C ../../../UTILS/src/
gcc -g $QC_FLAGS \
  ../test/count_bits.c \
  ../../../UTILS/src/mmap.c \
    $INCS -DDEBUG -lm -o count_bits
echo "Successfully completed $0 in $PWD"
