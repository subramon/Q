#!/bin/bash
set -e
gcc -g test_file_exists.c ../src/file_exists.c -std=gnu99 -I../inc/ -I../gen_inc/ -lm
./a.out "test_file_exists.c"
echo "SUCCESS for $0"
