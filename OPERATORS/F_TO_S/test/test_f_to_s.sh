#!/bibn/bash
set -e 
make -C ../lua/
INCS=" -I../inc/  -I../gen_inc -I../../../UTILS/inc -I../../../UTILS/gen_inc/ "
gcc -g -std=gnu99 test_f_to_s.c $INCS \
  ../gen_src/_sum_F8.c \
  ../gen_src/_min_I4.c \
  ../gen_src/_max_I1.c \
  ../../../UTILS/src/get_bit_u64.c \
  ../src/sum_B1.c \
  -o tst_f_to_s
valgrind ./tst_f_to_s 2>_x
set +e
grep 'ERROR SUMMARY' _x | grep ' 0 errors' 1>/dev/null 2>&1
status=$?
if [ $status != 0 ]; then echo FAILURE; else echo SUCCESS; fi 
echo "Completed $0 in $PWD"
rm _x
