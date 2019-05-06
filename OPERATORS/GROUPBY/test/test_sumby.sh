#!/bin/bash
set -e
test -d $Q_SRC_ROOT
cd ../lua/
# TODO make clean
# TODO make
cd -
gcc test_sumby.c  \
  -g $QC_FLAGS \
  $Q_SRC_ROOT/UTILS/src/get_bit_u64.c \
  ../gen_src/_sumby_I4_I1_I8.c \
  -I../gen_inc/ \
  -I../inc/ \
  -I../../../UTILS/inc/ \
  -I../../../UTILS/gen_inc/
./a.out
echo "Success on $0"
# rm -f a.out
