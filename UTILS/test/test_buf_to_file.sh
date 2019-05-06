#!/bin/bash
set -e
rm -f ./a.out
gcc  -g $QC_FLAGS test_buf_to_file.c \
  ../src/buf_to_file.c \
  ../src/rand_file_name.c \
  ../src/mix_UI8.c ../src/mix_UI4.c  \
  -std=gnu99 -I../inc/ -I../gen_inc/  -lm
valgrind --leak-check=full --show-leak-kinds=all ./a.out 
rm -f _*
echo "SUCCESS for $0"
