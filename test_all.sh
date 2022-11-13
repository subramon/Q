#!/bin/bash
set -e
# TODO P2 
# This is a very clumsy script. Should be replaced by testrunner
if [ "$LUA_PATH"  == "" ]; then echo "ERROR: source setup.sh"; exit 1; fi
if [ "$LUA_CPATH" == "" ]; then echo "ERROR: source setup.sh"; exit 1; fi

cd ~/Q/RUNTIME/VCTRS/src/
./ut1
./ut2
cd ~/Q/RUNTIME/VCTRS/test/
qjit test1.lua  
qjit test_lma.lua  
# TODO qjit test_memo.lua  
qjit test_ref_count.lua

cd ~/Q/OPERATORS/S_TO_F/test/
qjit  test_const.lua
qjit  test_period.lua
qjit  test_seq.lua
qjit  stress_test_const.lua

cd ~/Q/OPERATORS/F_TO_S/test/

cd ~/Q/OPERATORS/F1F2OPF3/test/

cd ~/Q/OPERATORS/SORT1/test/

cd ~/Q/OPERATORS/PERMUTE/test/

cd ~/Q/OPERATORS/WHERE/test/

echo "Successfully completed $0 in $PWD"
