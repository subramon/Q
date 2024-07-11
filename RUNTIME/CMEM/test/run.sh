#!/bin/bash
set -e 
cd ../src
make clean && make # Note that we do not use -DUSE_GLOBALS
cp libcmem.so ../test/
cd -
luajit test_cmem.lua
echo "Successfully completed $0 in $PWD"
