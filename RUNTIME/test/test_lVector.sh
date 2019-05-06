#!/bin/bash
set -e 
rm -f _*bin
export PATH=$PATH:../../UTILS/src
LJ=luajit
cd ../../UTILS/src/
bash mk_asc2bin.sh
cd -
which asc2bin 1>/dev/null 2>&1
asc2bin in1_I4.csv I4 _in1_I4.bin
asc2bin in1_B1.csv B1 _nn_in1.bin
$LJ test_lVector_reincarnate.lua

asc2bin in1_I4.csv I4 _in1_I4.bin
asc2bin in1_B1.csv B1 _nn_in1.bin
$LJ test_lVector_get_all.lua

asc2bin in1_I4.csv I4 _in1_I4.bin
asc2bin in1_B1.csv B1 _nn_in1.bin
cp _in1_I4.bin _in2_I4.bin
$LJ test_lVector.lua
rm -f _*bin
echo "Completed $0 in $PWD"
