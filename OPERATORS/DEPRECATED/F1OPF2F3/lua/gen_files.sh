#!/bin/bash
set -e
mkdir -p ../gen_src
mkdir -p ../gen_inc
rm -f ../gen_src/_*.c
rm -f ../gen_src/_*.o
rm -f ../gen_inc/_*.h

luajit lr_util_generator.lua lr_util_operators.lua

cd ../gen_src/
ls *c > _x
while read line; do
  gcc -c $line $QC_FLAGS -I../gen_inc -I../../../UTILS/inc/ 
done< _x
gcc $Q_LINK_FLAGS *.o -o libf1opf2f3.so
rm -f *.o
rm -f _x
cd -
lua pkg_f1opf2f3.lua
test -f f1opf2f3.lua
echo "ALL DONE: $0 in $PWD"
