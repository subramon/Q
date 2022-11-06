#!/bin/bash
set -e

if [ "$Q_ROOT"     == "" ]; then echo "ERROR: source setup.sh"; exit 1; fi
if [ "$Q_SRC_ROOT" == "" ]; then echo "ERROR: source setup.sh"; exit 1; fi

test -d $Q_ROOT
test -d $Q_SRC_ROOT

rm -f $Q_ROOT/csos/*.so
rm -f $Q_ROOT/lib/*.so

find $Q_SRC_ROOT -name "*.o" -print | xargs rm 
find $Q_SRC_ROOT -name "*.so" -print | xargs rm 

# Quick and dirty way of compiling. Need to improve this
cd $Q_SRC_ROOT/TMPL_FIX_HASHMAP/src/; make clean && make
cd $Q_SRC_ROOT/TMPL_FIX_HASHMAP/VCTR_HMAP/; make clean && make
cd $Q_SRC_ROOT/TMPL_FIX_HASHMAP/CHNK_HMAP/; make clean && make
cd $Q_SRC_ROOT/QJIT/GUTILS/; make clean && make
cd $Q_SRC_ROOT/RUNTIME/CUTILS/src/; make clean && make
cd $Q_SRC_ROOT/RUNTIME/CMEM/src/; make clean && make
cd $Q_SRC_ROOT/RUNTIME/SCLR/src/; make clean && make
cd $Q_SRC_ROOT/RUNTIME/VCTRS/src/; make clean && make
cd $Q_SRC_ROOT/QJIT/LuaJIT-2.1.0-beta3/src; rm -f ./luajit; make
echo "Q is good to go"
