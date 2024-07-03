#~/bin/bash
set -e
cd ../../VSPLIT/test
qjit  test_vsplit.lua
test -f _colF4.bin  
test -f _colI2.bin  
test -f _colI8.bin  
test -f _colSC.bin  
test -f _nn_colF4.bin  
test -f _nn_colI2.bin
cd -

qjit test_load_bin.lua

echo "Successfully vompleted $0 in $PWD"
