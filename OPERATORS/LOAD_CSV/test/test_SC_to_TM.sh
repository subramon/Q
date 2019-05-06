#!/bin/bash
set -e
gcc -g $QC_FLAGS  \
  test_SC_to_TM.c \
  ../src/SC_to_TM.c \
  ../src/TM_to_SC.c \
  ../src/TM_to_I8.c \
  -I../../../UTILS/inc -I../gen_inc/ -I../inc/ \
  -o a.out
./a.out

valgrind ./a.out 1>/tmp/_xx 2>&1
grep "0 errors from 0 contexts" /tmp/_xx 1>/dev/null 2>&1
rm -f /tmp/_xx
echo "Success for $0 in $PWD"
