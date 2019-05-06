#!/bin/bash
set -e 
gcc  test_trim.c ../src/trim.c -std=gnu99 -I../inc/ -I../gen_inc/ 
valgrind ./a.out 1>_out 2>_err
grep  "0 errors from 0 contexts" _err 1>/dev/null
grep  "SUCCESS" _out 1>/dev/null
echo "Successfully completed $0 in $PWD"
rm -f _*
