#!/bin/bash
set -e 
INCS="-I../gen_inc/ -I../../../UTILS/inc/ "
gcc $QC_FLAGS ../test/test_seq.c  \
    ${INCS} -DDEBUG -lm
actual=`./a.out`
expected="-10 -7 -4 -1 2 5 8 11 14 17 " 
if [ "$actual" != "$expected" ]; then echo FAILURE; exit 1; fi

gcc $QC_FLAGS ../test/test_period.c  \
    ${INCS} -DDEBUG -lm
actual=`./a.out`
expected="1.500000 1.750000 2.000000 2.250000 2.500000 1.500000 1.750000 2.000000 2.250000 2.500000 1.500000 "
if [ "$actual" != "$expected" ]; then echo FAILURE; exit 1; fi


echo "Successfully completed $0 in $PWD"
