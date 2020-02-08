#!/bin/bash
set -e
INCS=" -I../inc/ -I../../../UTILS/inc/ "
gcc -g ${INCS} $QC_FLAGS  \
  ../src/cprint.c \
  test_cprint.c 
  -o a.out
./a.out

valgrind ./a.out 1>/tmp/_xx 2>&1
grep "0 errors from 0 contexts" /tmp/_xx 1>/dev/null 2>&1
rm -f /tmp/_xx
echo "Success for $0 in $PWD"
