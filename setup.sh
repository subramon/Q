#!/bin/bash
set -e
CUR_DIR="`pwd`"
PREV_DIR="`cd -`"

unset Q_SRC_ROOT
unset Q_ROOT
unset QCFLAGS
unset QLDFLAGS

unset RSLUTILS_SRC_ROOT
unset RSUTILS_SRC_ROOT
unset RSHMAP_SRC_ROOT
unset CMEM_SRC_ROOT
unset SCLR_SRC_ROOT

export QISPC="false" # TODO P1 Should not be hard coded here

# Wont work with simlinks
Q_SRC_ROOT="$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
export Q_SRC_ROOT="${Q_SRC_ROOT}"
echo "Q_SRC_ROOT= ${Q_SRC_ROOT}"

export RSLUTILS_SRC_ROOT=$HOME/RSLUTILS/ # Where RSLUTILS has been checked out
export RSUTILS_SRC_ROOT=$HOME/RSUTILS/ # Where RSUTILS has been checked out
export RSHMAP_SRC_ROOT=$HOME/RSHMAP/  # Where  RSHMAP has been checked out
export CMEM_SRC_ROOT=$HOME/CMEM/  # Where  CMEM has been checked out
export SCLR_SRC_ROOT=$HOME/SCLR/  # Where  SCLR has been checked out
#-----------------------------------
export Q_ROOT="/home/ubuntu/local/Q/"
# export Q_ROOT="/mnt/storage/local/Q/"
# export Q_ROOT="/storeB/local/Q/"
echo "Q_ROOT= $Q_ROOT"
test -d $Q_ROOT/
mkdir -p $Q_ROOT/lib/
mkdir -p $Q_ROOT/cdefs/
mkdir -p $Q_ROOT/csos/
mkdir -p $Q_ROOT/config/
#-----------------------------------
QCFLAGS=" -std=gnu99  -fPIC     "
QCFLAGS+=" -g " # Comment for speed 
QCFLAGS+=" -DDEBUG " # Comment for speed 
# `QCFLAGS+=" -O3 " 
# QCFLAGS+=" -Ofast " # UnComment for speed 

# O3 covers most of the optimisations. The remaining options come 
# "at a cost". If you can tolerate some random rounding and your code 
# isn't dependent on IEEE floating point standards then you can try 
# -Ofast. This disregards standards compliance and can give you faster code.


QCFLAGS+=" -Wall -W -Waggregate-return -Wcast-align -Wmissing-prototypes"
QCFLAGS+=" -Wnested-externs -Wshadow -Wwrite-strings -Wunused-variable "
QCFLAGS+=" -Wunused-parameter -Wno-pedantic -fopenmp -Wno-unused-label " 
QCFLAGS+=" -Wmissing-declarations -Wredundant-decls -Wnested-externs "
QCFLAGS+=" -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith "
QCFLAGS+=" -Wshadow -Wcast-qual -Wcast-align -Wwrite-strings "
QCFLAGS+=" -Wold-style-definition -Wsuggest-attribute=noreturn "

# TODO P1 QLDFLAGS not being set correctly
export QLDFLAGS="${QLDFLAGS}"
echo "QLDFLAGS= $QLDFLAGS"

# TODO Consider whether to add the following
# Under Linux, when using GNU GCC, I have found it necessary to use the gold linker to get good results (-fuse-ld=gold): the default link frequently gives me errors when I try to use sanitizers.
#
# https://lemire.me/blog/2016/04/20/no-more-leaks-with-sanitize-flags-in-gcc-and-clang/
# NOT DOING THIS BECUASE WILL HAVE TO REWRITE TOO MUCH -Wjump-misses-init
# New GCC 6/7 flags:
set +e
lscpu | grep "Architecture" | grep "arm" 1>/dev/null 2>&1
IS_ARM_32="`echo $?`"
lscpu | grep "Architecture" | grep "aarch64" 1>/dev/null 2>&1
IS_ARM_64="`echo $?`"
set -e 
if [ $IS_ARM_32 == 0 ] || [ $IS_ARM_64 == 0 ]; then 
  QCFLAGS+=" -DARM "
  QCFLAGS+=" -Wno-cast-align " # too many warnings produced
  export Q_IS_ARM="true"
fi
export QCFLAGS="${QCFLAGS}"
echo "QCFLAGS= $QCFLAGS"

echo "Q_IS_ARM= $Q_IS_ARM"
#-----------------------------------
QISPC_FLAGS=' --pic  ' #- TODO to be set  P2
echo "QISPC_FLAGS= $QISPC_FLAGS"
echo "QISPC= $QISPC"
#-----------------------------------
export LD_LIBRARY_PATH="${Q_ROOT}/lib:/usr/local/lib64:${LD_LIBRARY_PATH}"
echo "LD_LIBRARY_PATH= $LD_LIBRARY_PATH"
#-----------------------------------

CURR_PATH=`pwd`
cd $Q_SRC_ROOT
cd ../
#- meta directory to LUA_PATH is for q_meta used to restore sessions
export LUA_PATH="${RSUTILS_SRC_ROOOT}/RSUTILS/lua/?.lua;${Q_ROOT}/meta/?.lua;${Q_ROOT}/config/?.lua;`pwd`/?.lua;`pwd`/?/init.lua;;"
export LUA_CPATH="${Q_ROOT}/lib/?.so;;"
cd $CURR_PATH
echo "LUA_PATH= $LUA_PATH"
echo "LUA_CPATH= $LUA_CPATH"
cd $PREV_DIR
cd $CUR_DIR 
export PATH=$PATH:$Q_ROOT/bin/

echo "Environment variables for Q good to go"
set +e

