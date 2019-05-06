#!/bin/bash
set -e
L=lua
LJ=luajit
echo "Create a small binary file for I4 called _in1_I4.bin"
rm -f _*bin
export PATH=$PATH:../../UTILS/src
cd ../../UTILS/src/
bash mk_asc2bin.sh
cd -
which asc2bin 1>/dev/null 2>&1
asc2bin in1_I4.csv I4 _in1_I4.bin
make -C ../src/

VG=valgrind
VG=""

$VG $L test_arith.lua
$VG $L test_cmem.lua
$VG $L test_eq.lua
$VG $L test_sclr.lua
$VG $L test_sclr_I8.lua
asc2bin in1_I4.csv I4 _in1_I4.bin
$VG $LJ test_vec.lua
asc2bin in1_I4.csv I4 _in1_I4.bin
$VG $LJ test_vec_writable.lua
$VG $LJ test_vec_prev_chunk.lua
$VG $LJ test_vec_no_chunk_num.lua
$VG $LJ test_vec_SC.lua
$VG $L test_bvec.lua
bash test_lVector.sh
asc2bin in1_I4.csv I4 _in1_I4.bin
$VG $LJ test_gen3.lua
$VG $LJ test_gen4.lua
echo "SUCCESS for $0 in $PWD"
