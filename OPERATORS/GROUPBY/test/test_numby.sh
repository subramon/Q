#!/bin/bash
set -e
test -d $Q_SRC_ROOT
cd ../lua/
make clean
make
cd -
gcc test_numby.c  \
  $Q_SRC_ROOT/UTILS/src/get_bit_u64.c \
  ../lua/libgroupby.so \
  -I../gen_inc/ \
  -I../inc/ \
  -I../../../UTILS/inc/ \
  -I../../../UTILS/gen_inc/
./a.out
echo "Success on $0"
rm -f a.out
