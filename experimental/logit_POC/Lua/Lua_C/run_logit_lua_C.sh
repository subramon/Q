#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
W_DIR=`pwd`
cd $SCRIPT_DIR/../../
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:."
cd $W_DIR

gcc -O4 -fopenmp -fPIC -std=gnu99 -shared  logit_I8.c -o liblogit_I8.so\
  $Q_SRC_ROOT/UTILS/src/rdtsc.c\
  -I$Q_SRC_ROOT/UTILS/gen_inc/ -lgomp -lm

luajit $SCRIPT_DIR/test_logit_lua_C.lua

