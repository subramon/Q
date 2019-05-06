#!/bibn/bash
set -e 
make -C ../../../UTILS/src/
make -C ../lua/ clean
make -C ../lua/ 
gcc -g -std=gnu99 \
  test_ifxthenyelsez.c \
  -I../gen_inc  \
  -I../../../UTILS/inc \
  -I../../../UTILS/gen_inc \
  ../gen_src/_vv_ifxthenyelsez_I4.c  \
  -o a.out
VG=" "
VG=" valgrind "
$VG ./a.out 1>_out 2>_x
diff _out out1.txt
grep 'C: SUCCESS' _x 1>/dev/null 2>&1
set +e
grep 'ERROR SUMMARY' _x | grep ' 0 errors' 1>/dev/null 2>&1
status=$?
if [ $status != 0 ]; then echo VG: FAILURE; else echo VG: SUCCESS; fi 
set -e 
#-------------------
rm _* a.out
echo "Completed $0 in $PWD"
