#!/bin/bash
set -e
# Remember to source ~/Q/setup.sh in order to set 
# Q_SRC_ROOT
# QC_FLAGS
INCS=" -I../foo/inc/  -I../../inc/ " # order is important
LIBS="../libkcfoo.so ../../src/libhmap.so "
cd ..
source to_source
rm -r -f foo/ # directory created for this specialization
lua lua/make_all.lua sample_configs.lua 
cd -
gcc -g test_kc.c ${INCS} -o test_kc ${LIBS} -ldl 
valgrind ./test_kc
echo "Complted $0 in $PWD"
