#!/bin/bash
set -e
make clean && make
export PATH=$PWD:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD
test_kUI8_vUI4
echo "Completed Successfully"
