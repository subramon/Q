#!/bin/bash
set -e

if [ "$Q_ROOT"     == "" ]; then echo "source setup.sh"; exit 1; fi 
if [ "$Q_SRC_ROOT" == "" ]; then echo "source setup.sh"; exit 1; fi 

test -d $Q_ROOT
rm -f $Q_ROOT/csos/*.so
rm -f $Q_ROOT/cdefs/*.*
rm -f $Q_ROOT/lib/*.so

test -f $Q_ROOT/config/q_config.lua

test -d $Q_SRC_ROOT
find $Q_SRC_ROOT -name  "*.o" -print | xargs rm  -f 
find $Q_SRC_ROOT -name "*.so" -print | xargs rm  -f

# Quick and dirty way of compiling. Need to improve this
test -d $RSUTILS_SRC_ROOT
DIR=$RSUTILS_SRC_ROOT/binding/src/
cd $DIR && make clean && make 
cp libcutils.so $Q_ROOT/lib/
cd -
#------------------------------------------------
test -d $RSUTILS_SRC_ROOT
DIR=$RSUTILS_SRC_ROOT/src/
cd $DIR && make clean && make 
cp librsutils.so $Q_ROOT/lib/
cd -
#------------------------------------------------
test -d $RSHMAP_SRC_ROOT
DIR=$RSHMAP_SRC_ROOT/fixed_len_kv/common/
cd $DIR && make clean && make
cp librs_hmap_core.so $Q_ROOT/lib/
cd -
#------------------------------------------------
DIR=$Q_SRC_ROOT/QJIT/HMAPS/CHNK/
cd $DIR && make clean && make
cp libchnk_rs_hmap.so $Q_ROOT/lib/
cd -
#------------------------------------------------
DIR=$Q_SRC_ROOT/QJIT/HMAPS/VCTR/
cd $DIR && make clean && make
cp libvctr_rs_hmap.so $Q_ROOT/lib/
cd -
#------------------------------------------------
DIR=$Q_SRC_ROOT/QJIT/GUTILS/
cd $DIR && make clean && make
cp libqjitaux.so $Q_ROOT/lib/
cp libcgutils.so $Q_ROOT/lib/
cp liblgutils.so $Q_ROOT/lib/
cd -
#------------------------------------------------
DIR=$Q_SRC_ROOT/RUNTIME/CMEM/src/
cd $DIR && make clean && make -f qMakefile
cp libcmem.so $Q_ROOT/lib/
cd -
#------------------------------------------------
DIR=$Q_SRC_ROOT/RUNTIME/SCLR/src/
cd $DIR && make clean && make 
cp libsclr.so $Q_ROOT/lib/
cd -
#------------------------------------------------
DIR=$Q_SRC_ROOT/RUNTIME/VCTR/src/
cd $DIR && make clean && make 
cp libvctr.so $Q_ROOT/lib/
cp libvctr_core.so $Q_ROOT/lib/
cd - #------------------------------------------------
DIR=$Q_SRC_ROOT/QJIT/LuaJIT-2.1.0-beta3/src; 
cd $DIR && rm -f ./luajit && make
cp luajit $Q_ROOT/bin/qjit
cd -
#------------------------------------------------

echo "Q is good to go"
