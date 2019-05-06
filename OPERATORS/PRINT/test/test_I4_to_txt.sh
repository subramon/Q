#!/bin/bash

gcc -I../gen_inc/ -I../../../UTILS/inc/ -std=c99 test_I4_to_txt.c ../gen_src/_I4_to_txt.c -o test.out

./test.out

rm test.out
