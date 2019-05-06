#!/bibn/bash
set -e 
make -C ../../../UTILS/src/
make -C ../lua/ clean
make -C ../lua/ 
gcc -g -std=gnu99 \
  test_ainb.c \
  ../../../UTILS/src/bytes_to_bits.c  \
  ../../../UTILS/src/bits_to_bytes.c \
  ../../../UTILS/gen_src/_bin_search_I8.c \
  -I../gen_inc  \
  -I../../../UTILS/inc \
  -I../../../UTILS/gen_inc \
  ../gen_src/_bin_search_ainb_I4_I8.c \
  ../gen_src/_simple_ainb_I4_I8.c \
  -o a.out
VG=" "
VG=" valgrind "
$VG ./a.out 2>_x
set +e
grep 'ERROR SUMMARY' _x | grep ' 0 errors' 1>/dev/null 2>&1
status=$?
if [ $status != 0 ]; then echo VG: FAILURE; else echo VG: SUCCESS; fi 
set -e 
#-------------------
luajit test_ainb.lua
rm _x a.out
echo "Completed $0 in $PWD"
