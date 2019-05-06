#!/bin/bash
set -e
gcc -g test_isdir.c ../src/isdir.c -std=gnu99 -I../inc/ -I../gen_inc/ -lm
./a.out "/tmp"
echo "SUCCESS for $0"
