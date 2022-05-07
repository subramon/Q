#!/bin/bash
set -e
make clean && make
export PATH=$PWD:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD
test1
test1a
test3
test4
test4a
test4b
test_fastrem
echo "Completed Successfully"
