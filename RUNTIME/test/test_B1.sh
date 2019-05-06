#!/bin/bash
set -e 
rm -f _*bin
export PATH=$PATH:../../../UTILS/src
which asc2bin 1>/dev/null 2>&1
asc2bin in2_B1.csv B1 _nn_in2.bin
luajit test_B1.lua
echo "Completed $0 in $PWD"
