#!/bin/bash
set -e 

# get the current directory in $SCRIPT_PATH
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH

cd $SCRIPT_PATH/
cd ../../../
export Q_SRC_ROOT="`pwd`"
export LUA_INIT="@$Q_SRC_ROOT/init.lua"
unset LD_LIBRARY_PATH
`lua | tail -1`

cd $SCRIPT_PATH/
rm -rf metadata/
mkdir metadata

luajit test_meta_data.lua $1

echo "Completed $0 in $PWD"

