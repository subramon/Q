#!/bin/bash
CUR_DIR="`pwd`"
PREV_DIR="`cd -`"

unset Q_SRC_ROOT
unset Q_ROOT
unset LUA_INIT
unset LD_LIBRARY_PATH
unset QC_FLAGS
unset Q_DATA_DIR
# TODO fix bug with ld library path
unset LD_LIBRARY_PATH

# Wont work with simlinks
Q_SRC_ROOT="$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
export Q_SRC_ROOT="${Q_SRC_ROOT}"
echo "Q_SRC_ROOT: ${Q_SRC_ROOT}"

export Q_ROOT="${Q_ROOT:=${HOME}/local/Q}"
echo "Q_ROOT: $Q_ROOT"
mkdir -p $HOME/local/
mkdir -p $Q_ROOT/include
mkdir -p $Q_ROOT/lib 
C_FLAGS=' -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -Wno-unused-parameter -pedantic -fopenmp -mavx2 -mfma -Wno-implicit-fallthrough'

export QC_FLAGS="${QC_FLAGS:=$C_FLAGS}"
lscpu | grep "Architecture" | grep "arm"
IS_ARM="`echo $?`"
if [ ${IS_ARM} -eq 0 ]; then 
  export QC_FLAGS=" $QC_FLAGS -DRASPBERRY_PI"
fi

echo "QC_FLAGS: $QC_FLAGS"
mkdir -p $Q_ROOT/data
export Q_DATA_DIR="${Q_DATA_DIR:=${Q_ROOT}/data}"
echo "Q_DATA_DIR: $Q_DATA_DIR"
mkdir -p $Q_ROOT/meta

export LD_LIBRARY_PATH="${Q_ROOT}/lib:/usr/local/lib64:${LD_LIBRARY_PATH}"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
# export Q_LINK_FLAGS=" -shared -lpthread -lm -lgomp "
export Q_LINK_FLAGS=" -llapacke -llapack -lblas -lm -shared -lgomp"
echo "Q_LINK_FLAGS: $Q_LINK_FLAGS"
CURR_PATH=`pwd`
cd $Q_SRC_ROOT
cd ../
export LUA_PATH="`pwd`/?.lua;`pwd`/?/init.lua;;"
export LUA_CPATH="${Q_ROOT}/lib/?.so;;"
cd $CURR_PATH
echo "LUA_PATH: $LUA_PATH"
echo "LUA_CPATH: $LUA_CPATH"
cd $PREV_DIR
cd $CUR_DIR 
