#!/bibn/bash
set -e 
make -C ../lua/ clean
make -C ../lua/
gcc -g ${QC_FLAGS}  \
  -I../gen_inc \
  -I../../../UTILS/inc \
  test_drg_sort.c \
  ../gen_src/_qsort_asc_val_F8_drg_I4.c \
  ../gen_src/_qsort_dsc_val_I8_drg_I2.c \
  -o a.out
VG="valgrind --leak-check=full " 
$VG --leak-check=full ./a.out 1>_out  2>_err
grep 'SUCCESS' _out | 1>/dev/null 2>&1
set +e
grep 'ERROR SUMMARY' _err | grep ' 0 errors' 1>/dev/null 2>&1
status=$?
if [ $status != 0 ]; then echo FAILURE; else echo SUCCESS; fi 
rm -f _* a.out
make -C ../lua/ clean
echo "Completed $0 in $PWD"
