#!/bin/bash
set -e
# TODO P2 
# This is a very clumsy script. Should be replaced by testrunner
if [ "$LUA_PATH"  == "" ]; then echo "ERROR: source setup.sh"; exit 1; fi
if [ "$LUA_CPATH" == "" ]; then echo "ERROR: source setup.sh"; exit 1; fi
# TODO P0 Put cVector.check_all(true, true) at end of every script
# TODO P0 Put vector:check() for every vector created 

cd ~/Q/RUNTIME/VCTRS/src/
./ut1
./ut2
cd ~/Q/RUNTIME/VCTRS/test/
qjit test1.lua  
qjit test_lma.lua  
qjit test_memo.lua  
qjit test_ref_count.lua

cd ~/Q/OPERATORS/LOAD_CSV/test/
qjit test_load_csv.lua
qjit test_SC_to_XX.lua
qjit test_SC_to_TM1.lua

cd ~/Q/OPERATORS/S_TO_F/test/
qjit  test_const.lua
qjit  test_period.lua
qjit  test_seq.lua
# TODO qjit  test_rand.lua
qjit  stress_test_const.lua

cd ~/Q/OPERATORS/F_TO_S/test/
qjit test_f_to_s.lua
qjit test_fold.lua
qjit test_sum.lua
bash test_f_to_s.sh

cd ~/Q/OPERATORS/F1F2OPF3/test/
qjit test_concat.lua
qjit test_vveq.lua
qjit test_vvsub.lua
qjit test_repeater.lua
# TODO qjit test_logical_op.lua

cd ~/Q/OPERATORS/SORT1/test/
qjit test_sort.lua

cd ~/Q/OPERATORS/PERMUTE/test/
qjit test_permute.lua

cd ~/Q/OPERATORS/WHERE/test/
qjit test_where.lua
qjit test_where_gen.lua
# TODO P0 qjit test_select_ranges.lua
bash run_tests.sh

echo "Successfully completed $0 in $PWD"
