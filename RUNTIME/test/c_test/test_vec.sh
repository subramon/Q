#!/bin/bash
set -e 
#rm -f _*
INCS=" -I../ -I../../src/ -I../../inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ -I../../../UTILS/inc/ -I../../../OPERATORS/LOAD_CSV/gen_inc/ -I../../../OPERATORS/PRINT/gen_inc/ "
gcc -g $QC_FLAGS $INCS \
  test_nascent_vec.c \
  ../../../UTILS/src/err.c \
  ../../src/core_vec.c \
  ../../../UTILS/src/mmap.c \
  ../../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I4.c \
  ../../../UTILS/src/is_valid_chars_for_num.c \
  ../../../UTILS/src/rand_file_name.c \
  ../../../UTILS/src/get_file_size.c \
  ../../../UTILS/src/buf_to_file.c \
  ../../../UTILS/src/file_exists.c \
  -o nascent.out -lm

gcc -g $QC_FLAGS $INCS \
  test_materialized_vec.c \
  ../../../UTILS/src/err.c \
  ../../src/core_vec.c \
  ../../../UTILS/src/mmap.c \
  ../../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I4.c \
  ../../../UTILS/src/is_valid_chars_for_num.c \
  ../../../UTILS/src/rand_file_name.c \
  ../../../UTILS/src/get_file_size.c \
  ../../../UTILS/src/buf_to_file.c \
  ../../../UTILS/src/file_exists.c \
  -o materialized.out -lm
#valgrind  --show-leak-kinds=all --leak-check=full ./nascent.out 1>_x 2>&1
#grep "ERROR SUMMARY: 0 errors from 0 contexts" _x 1>/dev/null
#rm -f _*
echo SUCCESS for $0
