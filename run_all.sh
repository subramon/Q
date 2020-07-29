#!/bin/bash
# set -e 
test -d $Q_SRC_ROOT
rm -f _log
luajit ~/Q/TEST_RUNNER/runtest.lua $Q_SRC_ROOT/RUNTIME/CUTILS/test 1>>_log 2>&1
luajit ~/Q/TEST_RUNNER/runtest.lua $Q_SRC_ROOT/RUNTIME/CMEM/test 1>>_log 2>&1
luajit ~/Q/TEST_RUNNER/runtest.lua $Q_SRC_ROOT/RUNTIME/SCLR/test 1>>_log 2>&1
# luajit ~/Q/TEST_RUNNER/runtest.lua $Q_SRC_ROOT/RUNTIME/VCTR/test 1>>_log 2>&1
#---------------------------------
luajit ~/Q/TEST_RUNNER/runtest.lua $Q_SRC_ROOT/OPERATORS/F_IN_PLACE/test 1>>_log 2>&1
luajit ~/Q/TEST_RUNNER/runtest.lua $Q_SRC_ROOT/OPERATORS/F1F2_IN_PLACE/test 1>>_log 2>&1
luajit ~/Q/TEST_RUNNER/runtest.lua $Q_SRC_ROOT/OPERATORS/F_TO_S/test 1>>_log 2>&1
luajit ~/Q/TEST_RUNNER/runtest.lua $Q_SRC_ROOT/OPERATORS/MK_COL/test 1>>_log 2>&1
luajit ~/Q/TEST_RUNNER/runtest.lua $Q_SRC_ROOT/OPERATORS/S_TO_F/test 1>>_log 2>&1
luajit ~/Q/TEST_RUNNER/runtest.lua $Q_SRC_ROOT/OPERATORS/F1F2OPF3/test 1>>_log 2>&1
luajit ~/Q/TEST_RUNNER/runtest.lua $Q_SRC_ROOT/OPERATORS/F1S1OPF2/test 1>>_log 2>&1
luajit ~/Q/TEST_RUNNER/runtest.lua $Q_SRC_ROOT/OPERATORS/LOAD_CSV/test 1>>_log 2>&1
luajit ~/Q/TEST_RUNNER/runtest.lua $Q_SRC_ROOT/OPERATORS/WHERE/test 1>>_log 2>&1
set +e
grep FAILURE _log
status=$?
if [ $status != 1 ]; then echo FAILURE; exit 1; fi 
echo "All done"
