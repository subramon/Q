#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
W_DIR=`pwd`
cd $SCRIPT_DIR/../../
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:."
cd $W_DIR

gcc -O4 -fPIC -std=gnu99 -shared  vvadd_I4_I4_I4.c -o libvvadd_I4_I4_I4.so
if [ $# -ne 1 ] 
then
 echo -e "Usage:\nbash run_vvadd.sh <luajit/lua>"
 exit
fi

if [ $1 == "luajit" ]
then
  luajit $SCRIPT_DIR/run_vvadd.lua
elif [ $1 == "lua" ]
then
  lua $SCRIPT_DIR/run_vvadd.lua
else
  echo "Provide appropriate first argument (interpreter name  <luajit/lua>)"
fi
