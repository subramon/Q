#!/bin/bash
set -e 
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:~/Q/TMPL_FIX_HASHMAP/HW2/:~/Q/TMPL_FIX_HASHMAP/HELLO_WORLD/"

echo $LD_LIBRARY_PATH
# FOLLOWING IS A HACK. FIX TODO P3. Setting LD_LIBRARY_PATH not working 
cp ~/Q/TMPL_FIX_HASHMAP/HW2/lib*so .
cp ~/Q/TMPL_FIX_HASHMAP/HELLO_WORLD/lib*so .
cp ~/Q/TMPL_FIX_HASHMAP/src/lib*so .

INCS=" -I../inc/ -I ../../HELLO_WORLD/inc/ -I../../inc/"
gcc ${INCS} ${QCFLAGS} test_hw1hw2.c \
  libhmap_hw2.so libhmap_hw.so libhmap.so -o test_hw1hw2 ${QLDFLAGS} -ldl

exit 0;
./test_hw1hw2
