#!/bin/bash
set -e 
# TODO P3 Why is this seg faulting?
CGLAGS="-g $QC_FLAGS"
gcc -g  -I../inc/  \
  -mavx2 -mfma -DAVX \
  ../src/avx.c test_dp.c \
  -o test_dp
./test_dp
echo "Success for $0 in $PWD"
rm -f ./test_dp
