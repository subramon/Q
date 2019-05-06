#!/bin/bash
set -e 
cd ../src/
bash gen_files.sh
cd -

WARN=" -g -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align
-Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic "
gcc $WARN $FLAGS -I../gen_inc -I../inc/  \
  ../src/bytes_to_bits.c \
  ../src/bits_to_bytes.c \
  test_bytes_to_bits.c 

./a.out
echo "Completed $0 in $PWD"
