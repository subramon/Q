#!/bin/bash
if [ -z "$Q_SRC_ROOT" ]  
then
  echo "ERR: run setup.sh from Q source root dir"
  exit -1
fi
luajit $Q_SRC_ROOT/UTILS/lua/test_runner.lua Q/OPERATORS/MK_COL/lua/mk_col Q/OPERATORS/MK_COL/test/testsuite_mkcol $1
rm -f _*
