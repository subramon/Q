#!/bin/bash
set -e 
gcc $QCFLAGS \
  -I../inc/ \
  ../src/rs_mmap.c \
  ../src/isdir.c \
  ../src/isfile.c \
  ../src/file_split.c \
  ../src/lookup8.c \
  test_file_split.c \
  -o file_split
nfiles=4
iter=2
while [ $iter -le $nfiles ]; do
  infile="/mnt/storage/ascdata/price_cds/00000${iter}_0"
  opdir="/mnt/storage/ascdata/price_cds/"
  nB=32
  split_col_idx=0
  ./file_split "$infile" "$opdir" $nB $split_col_idx
  iter=`expr $iter + 1`
done
echo "Completed test $0 in $PWD"
