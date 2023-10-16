#!/bin/bash
set -e
# Remember to source ~/Q/setup.sh in order to set 
# Q_SRC_ROOT
# QC_FLAGS
INCS=" -I../foo/inc/  -I../../inc/ -I../../../UTILS/inc/ " # order is important
LIBS="../libkcfoo.so ../../src/libhmap.so "
cd ..
rm -r -f foo/ # directory created for this specialization
lua lua/cli_make_kc_so.lua sample_configs.lua 
cd -
gcc -g test_kc.c ${INCS} -o test_kc ${LIBS} -ldl 
valgrind ./test_kc
echo "=============================="
gcc -g test_permute.c ${INCS} -o test_permute ${LIBS} -ldl 
valgrind ./test_permute
echo "Complted $0 in $PWD"
