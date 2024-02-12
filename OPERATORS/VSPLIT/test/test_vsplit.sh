#!/bin/bash
set -e
rm -f outfile*.bin
gcc -g $QCFLAGS  \
  test_vsplit.c \
  ../src/vsplit.c \
  ../../LOAD_CSV/src/asc_to_bin.c \
  ../../LOAD_CSV/src/get_fld_sep.c \
  ../../LOAD_CSV/src/get_cell.c \
  ../../LOAD_CSV/src/chk_data.c \
  ../../../UTILS/src/txt_to_I1.c \
  ../../../UTILS/src/txt_to_I2.c \
  ../../../UTILS/src/txt_to_I4.c \
  ../../../UTILS/src/txt_to_I8.c \
  ../../../UTILS/src/txt_to_UI1.c \
  ../../../UTILS/src/txt_to_UI2.c \
  ../../../UTILS/src/txt_to_UI4.c \
  ../../../UTILS/src/txt_to_UI8.c \
  ../../../UTILS/src/txt_to_F4.c \
  ../../../UTILS/src/txt_to_F8.c \
  ../../../UTILS/src/rs_mmap.c \
  ../../../UTILS/src/set_bit_u64.c \
  ../../../UTILS/src/trim.c \
  -I../../../UTILS/inc -I../gen_inc/ -I../inc/ -I../../LOAD_CSV/inc/ \
  -o a.out -lgomp
./a.out

valgrind ./a.out 1>/tmp/_xx 2>&1
grep "0 errors from 0 contexts" /tmp/_xx 1>/dev/null 2>&1
# rm -f outfile*.bin
echo "Success for $0 in $PWD"
