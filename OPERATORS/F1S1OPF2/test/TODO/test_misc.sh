#!/bin/bash
set -e 
INCS=" -I.  -I../../../UTILS/inc/ -I../gen_inc/ "
test -f ../lua/libf1s1opf2.so
if [ $? != 0 ]; then 
  cd ../lua/
  bash gen_files.sh
  cd -
fi
#---------------
gcc -g ${INCS} ${QC_FLAGS} -Werror explog.c ../lua/libf1s1opf2.so -lm
valgrind ./a.out 2>_x
set +e
grep 'ERROR SUMMARY' _x | grep ' 0 errors' 1>/dev/null 2>&1
status=$?
if [ $status != 0 ]; then echo VG: FAILURE; else echo VG: SUCCESS; fi 
set -e 
#-------------------
gcc -g ${INCS} ${QC_FLAGS} -Werror eq.c ../lua/libf1s1opf2.so -lm
valgrind ./a.out 2>_x
set +e
grep 'ERROR SUMMARY' _x | grep ' 0 errors' 1>/dev/null 2>&1
status=$?
if [ $status != 0 ]; then echo VG: FAILURE; else echo VG: SUCCESS; fi 
set -e 
#-------------------
rm -f _*
rm -f a.out
touch ../lua/_ctests
echo "Completed $0 in $PWD"
