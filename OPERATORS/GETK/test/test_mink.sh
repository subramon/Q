#/bin/bash
set -e 
gcc -g -std=c99 $QC_FLAGS test_mink.c ../src/mink.c \
  -I../inc/ -I../../../UTILS/inc/ \
  -o test_mink
VG="valgrind --leak-check=full" 
$VG ./test_mink 1>_x 2>&1
grep "0 errors from 0 contexts" _x 1>/dev/null 2>&1
rm _x test_mink
echo "Successfully completed $0 in $PWD"
