#!/bin/bash 
set -e 

# get the current directory in $SCRIPT_PATH
# SCRIPT=$(readlink -f "$0")
# SCRIPT_PATH=$(dirname "$SCRIPT")
# echo $SCRIPT_PATH
# 
# cd $SCRIPT_PATH
# cd ../../../
# export Q_SRC_ROOT="`pwd`"
# export LUA_INIT="@$Q_SRC_ROOT/init.lua"
# unset LD_LIBRARY_PATH
# `lua | tail -1`
# 
# # generate vector lib files
# cd $SCRIPT_PATH/../../../RUNTIME/COLUMN/code/src
# bash gen_files.sh
# make
# 
# cd $SCRIPT_PATH/
luajit test_mkcol.lua 
if [ $? != 0 ]; then echo FAILURE; exit 1; fi 

rm -f _*
echo "Completed $0 in $PWD"
