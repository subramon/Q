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
./file_split
echo "Completed test $0 in $PWD"
