#!/bin/bash
infile=../../../DATA_SETS/MNIST/mnist.tar.gz
test -f $infile
cp $infile .
tar -zxvf $infile
set -e
rm -r -f  _test_files
mkdir     _test_files
rm -f /tmp/_*.bin
make clean
make
VG=" valgrind --leak-check=full "
VG=""
#-----------------------------------
$VG ./test_load_csv_fast 1048576 1>_out 2>_err
grep SUCCESS _out 1>/dev/null 2>&1
if [ "$VG" != "" ]; then 
  grep "0 errors from 0 contexts" _err 1>/dev/null 2>&1
fi
rm -r -f mnist
#-----------------------------------
$VG ./stress_test_load_csv_fast 1024 1>_out 2>_err
grep SUCCESS _out 1>/dev/null 2>&1
if [ "$VG" != "" ]; then 
  grep "0 errors from 0 contexts" _err 1>/dev/null 2>&1
fi
#-----------------------------------
./stress_test_load_csv_fast 1048476 1>_out 2>_err
grep SUCCESS _out 1>/dev/null 2>&1
grep "0 errors from 0 contexts" _err 1>/dev/null 2>&1
#-----------------------------------
rm -f /tmp/_*.bin
make clean
echo "Completed $0 in $PWD"

