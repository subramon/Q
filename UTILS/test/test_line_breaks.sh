#!/bin/bash
set -e
gcc $QCFLAGS test_line_breaks.c \
  ../src/line_breaks.c ../src/rs_mmap.c \
  -I../inc/ 
valgrind --track-origins=yes --leak-check=full ./a.out test_line_breaks.c _xx
test -f _xx
# Remove output files
rm -f _xx
echo "SUCCESS for $0"
