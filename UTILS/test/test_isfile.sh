#!/bin/bash
set -e
gcc -g test_isfile.c ../src/isfile.c -std=gnu99 -I../inc/ -I../gen_inc/ -lm
./a.out "test_isfile.c"
echo "SUCCESS for $0"
