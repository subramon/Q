#!/bin/bash
set -e 
rm -r -f ../gen_src/; mkdir -p ../gen_src
rm -r -f ../gen_inc/; mkdir -p ../gen_inc
lua generator.lua 
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $QC_FLAGS $line -I../gen_inc -I../../../UTILS/inc/
done< _x
gcc $Q_LINK_FLAGS *.o -o libsort.so
rm -f _x
cd -
echo "ALL DONE"
