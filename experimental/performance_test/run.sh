#!/bin/bash

bash build.sh
gcc -O4 -std=gnu99 -DSTAND_ALONE add.c -o add

n=100000000
time ./add $n
time luajit ffi_add.lua $n
time lua c_api_add.lua $n

rm -f a.out _* libadd.so add.so add
