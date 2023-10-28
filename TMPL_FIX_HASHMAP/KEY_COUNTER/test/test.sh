#!/bin/bash
set -e
# Remember to source ~/Q/setup.sh in order to set 
# Q_SRC_ROOT
# QC_FLAGS
INCS=" -I../foo/inc/  -I../../inc/ -I../../../UTILS/inc/ " # order is important
# Note that libkcfoo.fo is in $Q_ROOT/lib/
LIBS=" ../libkcfoo.so ../../src/libhmap.so "
cd ..
rm -f $Q_ROOT/lib/libkcfoo.so 
rm -r -f foo/ # directory created for this specialization
lua lua/cli_make_kc_so.lua sample_configs.lua 
cd -
mv $Q_ROOT/lib/libkcfoo.so .. # test_kc expects this .so to be in ..
gcc -g test_kc.c ${INCS} -o test_kc ${LIBS} -ldl 
valgrind ./test_kc
echo "=============================="
gcc -g test_permute.c ${INCS} -o test_permute ${LIBS} -ldl 
valgrind ./test_permute
# cleanup
cd ..
rm  -rf foo/
rm  -f libkcfoo.so 
#-----
echo "Complted $0 in $PWD"
