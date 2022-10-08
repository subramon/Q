#!/bin/bash
set -e
# Quick and dirty way of compiling. Need to improve this
cd $Q_SRC_ROOT/RUNTIME/CUTILS/src/; make clean && make
cd $Q_SRC_ROOT/RUNTIME/CMEM/src/; make clean && make
cd $Q_SRC_ROOT/RUNTIME/SCLR/src/; make clean && make
cd $Q_SRC_ROOT/RUNTIME/VCTRS/src/; make clean && make
cd $Q_SRC_ROOT/TMPL_FIX_HASHMAP/src/; make clean && make
cd $Q_SRC_ROOT/TMPL_FIX_HASHMAP/VCTR_HMAP/; make clean && make
cd $Q_SRC_ROOT/TMPL_FIX_HASHMAP/CHNK_HMAP/; make clean && make
cd $Q_SRC_ROOT/QJIT/GUTILS/; make clean && make
cd $Q_SRC_ROOT/QJIT/LuaJIT-2.1.0-beta3/src; make
echo "Q is good to go"
