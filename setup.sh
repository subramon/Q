#!/bin/bash
CUR_DIR="`pwd`"
PREV_DIR="`cd -`"

unset Q_SRC_ROOT
unset Q_ROOT
unset QC_FLAGS
unset Q_DATA_DIR

# Wont work with simlinks
Q_SRC_ROOT="$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
export Q_SRC_ROOT="${Q_SRC_ROOT}"
echo "Q_SRC_ROOT: ${Q_SRC_ROOT}"
#-----------------------------------
export Q_ROOT="${Q_ROOT:=${HOME}/local/Q}"
echo "Q_ROOT: $Q_ROOT"
mkdir -p $HOME/local/
mkdir -p $HOME/local/Q/
mkdir -p $HOME/local/Q/lib/
#-----------------------------------
C_FLAGS=" -g -std=gnu99  -fPIC"
C_FLAGS+=" -Wall -W -Waggregate-return -Wcast-align -Wmissing-prototypes"
C_FLAGS+=" -Wnested-externs -Wshadow -Wwrite-strings -Wunused-variable "
C_FLAGS+=" -Wunused-parameter -Wno-pedantic -fopenmp -Wno-unused-label " 
C_FLAGS+=" -Wmissing-declarations -Wredundant-decls -Wnested-externs "
C_FLAGS+=" -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith "
C_FLAGS+=" -Wshadow -Wcast-qual -Wcast-align -Wwrite-strings "
C_FLAGS+=" -Wold-style-definition -Wsuggest-attribute=noreturn "

#
# CFLAGS+= -fsanitize=address -fno-omit-frame-pointer 
# CFLAGS+= -fsanitize=undefined
# https://lemire.me/blog/2016/04/20/no-more-leaks-with-sanitize-flags-in-gcc-and-clang/
# NOT DOING THIS BECUASE WILL HAVE TO REWRITE TOO MUCH -Wjump-misses-init
# New GCC 6/7 flags:
lscpu | grep "Architecture" | grep "arm"
IS_ARM="`echo $?`"
if [ ${IS_ARM} -eq 0 ]; then 
  C_FLAGS+=" -DARM "
  export Q_IS_ARM="true"
else
  C_FLAGS+=" -Wduplicated-cond -Wmisleading-indentation -Wnull-dereference "
  C_FLAGS+=" -Wduplicated-branches -Wrestrict "
fi
export QC_FLAGS="${QC_FLAGS:=$C_FLAGS}"
echo "QC_FLAGS: $QC_FLAGS"
#-----------------------------------
QISPC_FLAGS=' --pic  ' #- TODO to be set  P2
echo "QISPC_FLAGS: $QISPC_FLAGS"
#-----------------------------------
# Default data directory
mkdir -p $Q_ROOT/data
export Q_DATA_DIR="${Q_DATA_DIR:=${Q_ROOT}/data}"
echo "Q_DATA_DIR: $Q_DATA_DIR"
#-----------------------------------
export LD_LIBRARY_PATH="${Q_ROOT}/lib:/usr/local/lib64:${LD_LIBRARY_PATH}"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
#-----------------------------------

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
