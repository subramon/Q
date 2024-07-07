#!/bin/bash
set -e 
CGLAGS="-g $QC_FLAGS"
gcc -g  -I../inc/  -I../../../UTILS/inc/ \
  -mavx2 -mfma -DAVX \
  ../src/avx.c test_fma.c \
  -o test_fma
./test_fma > _1
#-- repeat but compile without AVX
gcc -g  -I../inc/ -I../../../UTILS/inc/ \
  -mavx2 -mfma \
  ../src/avx.c test_fma.c \
  -o test_fma
./test_fma > _2
# should get same result
diff _1 _2
echo "Success for $0 in $PWD"
rm -f ./test_fma
