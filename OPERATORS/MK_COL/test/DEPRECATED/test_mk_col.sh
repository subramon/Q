#!/bin/bash 
set -e 

# get the current directory in $SCRIPT_PATH
# SCRIPT=$(readlink -f "$0")
# SCRIPT_PATH=$(dirname "$SCRIPT")
# echo $SCRIPT_PATH
# 
# cd $SCRIPT_PATH
# cd ../../../../
# export Q_SRC_ROOT="`pwd`"
# # echo $LD_LIBRARY_PATH
# export LUA_INIT="@$Q_SRC_ROOT/init.lua"
# 
# unset LD_LIBRARY_PATH
# `lua | tail -1`
# 
# cd $SCRIPT_PATH
# 
# #run test_load_csv
luajit -lluacov test_mkcol.lua $1
luacov
rm -f _*
