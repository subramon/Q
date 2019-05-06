#!/bin/bash
set -e 
rm -r -f ../gen_src/; mkdir -p ../gen_src
rm -r -f ../gen_inc/; mkdir -p ../gen_inc
luajit generator.lua operators.lua

cd ../gen_src/
ls *c > _x
while read line; do
  gcc -c $line $QC_FLAGS -I../gen_inc -I../../../UTILS/inc/ 
done< _x
gcc $Q_LINK_FLAGS *.o -o libf_to_s.so
rm -f *.o 
rm -f _x
cd -
luajit pkg_f_to_s.lua
test -f _f_to_s.lua
echo "ALL DONE: $0 in $PWD"
