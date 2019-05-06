#!/bin/bash
gcc  test_rand_file_name.c ../src/rand_file_name.c -std=gnu99 -I../inc/ -I../gen_inc/ ../src/mix_UI8.c ../src/mix_UI4.c 
valgrind ./a.out 
