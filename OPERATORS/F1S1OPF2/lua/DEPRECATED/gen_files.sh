#!/bin/bash
set -e
bash clean.sh
rm -r -f ../gen_inc; mkdir -p ../gen_inc/
rm -r -f ../gen_src; mkdir -p ../gen_src/
lua gen_specializers.lua
luajit generator0.lua  operators0.lua
luajit generator1.lua  arith_operators.lua
luajit generator1.lua  cmp_operators.lua
# WONTFIX luajit generator2.lua  cmp2_operators.lua

cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $line $QC_FLAGS -I../gen_inc -I../../../UTILS/inc/ 
done< _x
gcc $Q_LINK_FLAGS *.o -o libf1s1opf2.so
rm -f *.o 
rm -f _x
cd -
echo "ALL DONE; $0 in $PWD"
