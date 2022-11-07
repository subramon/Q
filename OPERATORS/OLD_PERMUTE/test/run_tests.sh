#!/bin/bash
if [ -z "$Q_SRC_ROOT" ]  
then
  echo "ERR: run setup.sh from Q source root dir"
  exit -1
fi
CDIR=`pwd`

luajit -e "require('terra')" $Q_SRC_ROOT/UTILS/lua/test_runner.lua Q/OPERATORS/PERMUTE/terra/permute Q/OPERATORS/PERMUTE/test/testsuite_permute $1
