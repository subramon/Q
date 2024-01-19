#!/bin/bash
set -e
# Clean output files
rm -f rslt_test_test_copy_file.c rslt_test_dictionary.lua
gcc $QCFLAGS test_copy_file.c \
  ../src/copy_file.c ../src/get_file_size.c ../src/rs_mmap.c \
  -I../inc/ 
valgrind --track-origins=yes --leak-check=full ./a.out test_copy_file.c _xx
test -f _xx
# Remove output files
rm -f rslt_test_test_copy_file.c 
echo "SUCCESS for $0"
