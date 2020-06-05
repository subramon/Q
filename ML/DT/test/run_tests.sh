#!/bibn/bash
set -e 
make -C ../../../UTILS/src/
make -C ../lua/ clean
make -C ../lua/
gcc -g -std=gnu99 \
  test_cum_for_dt.c \
  -I../gen_inc  \
  -I../../../UTILS/inc \
  -I../../../UTILS/gen_inc \
  ../gen_src/_cum_for_dt_F4_I4.c \
  -o a.out -lm
VG=" "
VG=" valgrind "
$VG ./a.out 2>_x
set +e
grep 'ERROR SUMMARY' _x | grep ' 0 errors' 1>/dev/null 2>&1
status=$?
if [ $status != 0 ]; then echo VG: FAILURE; else echo VG: SUCCESS; fi
set -e 
#-------------------
#luajit test_cum_for_dt.lua
#rm _x a.out
echo "Completed $0 in $PWD"
