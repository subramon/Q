#!/bin/bash
set -e
gcc -g $QC_FLAGS  \
  test_SC_to_TM.c \
  ../src/SC_to_TM.c \
  -I../../../UTILS/inc -I../inc/ \
  -o a.out

valgrind ./a.out
echo "Success for $0 in $PWD"
