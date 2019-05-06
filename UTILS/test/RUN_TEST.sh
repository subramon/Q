#!/bin/bash
set -e

ld_library_add() {
    if [ -d "$1" ] && [[ ":$LD_LIBRARY_PATH:" != *":$1:"* ]]; then
       LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+"$LD_LIBRARY_PATH:"}$1"
       export LD_LIBRARY_PATH
    fi
}

ld_library_add ../../../RUNTIME/COLUMN/code/
ld_library_add ../obj/
ld_library_add ../../PRINT/obj/


echo "-----------------------------"
echo "Running Dictionary Test Cases"
echo "-----------------------------"
luajit -lluacov test_dictionary.lua

echo "-----------------------------"
echo "Running Lua Test Cases"
echo "-----------------------------"
luajit -lluacov test_utils.lua

echo "-----------------------------"
echo "Generating Code Coverage Report"
echo "-----------------------------"
luacov
echo "OK"


echo "----------------------------"
echo "DONE"
