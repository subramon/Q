#!/bin/bash
set -e 
gcc -std=gnu99 -fPIC -shared -xc -o libload_csv.so \
   ../src/get_cell.c \
   ../../../UTILS/src/f_mmap.c \
   ../../../UTILS/src/f_munmap.c \
   ../gen_src/_txt_to_I4.c \
   ../gen_src/_txt_to_F4.c \
   ../../PRINT/gen_src/_I4_to_txt.c \
  ../../PRINT/gen_src/_F4_to_txt.c \
   ../../../UTILS/src/is_valid_chars_for_num.c \
   -I../../../UTILS/inc \
   -I../../../UTILS/gen_inc \
   -I../gen_inc \
   -I../../PRINT/gen_inc

echo "Completed $0 in $PWD"
exit 0
# Following is to test print/load 

cd ../../../RUNTIME/COLUMN/code
make clean
make all
cd -
export LD_LIBRARY_PATH='./;../../../RUNTIME/COLUMN/code' 
# luajit ./load.lua
luajit ./print_csv.lua

