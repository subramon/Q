#!/bin/bash
set -e 
gcc  $QC_FLAGS -g \
  test_get_bit_u64.c \
  ../src/get_bit_u64.c  \
  ../src/rdtsc.c  \
  -I../inc/ -I../gen_inc/ 
valgrind --track-origins=yes --leak-check=full ./a.out 
echo "SUCCESS for $0"
