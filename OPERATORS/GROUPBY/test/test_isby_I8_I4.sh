#!/bin/bash
set -e 
gcc $QC_FLAGS test_isby_I8_I4.c ../src/isby_I8_I4.c -o test_isby_I8_I4 \
  -I../inc/ -I../../../UTILS/inc/
./test_isby_I8_I4
echo "Completed $0 in $PWD"
