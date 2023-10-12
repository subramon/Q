#!/bin/bash
set -e
INCS=" -I../foo/inc/  -I../../inc/ " # order is important
LIBS="../libkcfoo.so ../../src/libhmap.so "
gcc -g test_kc.c ${INCS} -o test_kc ${LIBS} -ldl 
valgrind ./test_kc
echo "Complted $0 in $PWD"
