#!/bin/bash
set -e 
lua generator.lua 
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc $QC_FLAGS -c $line -I../gen_inc -I../../../UTILS/inc/
done< _x
gcc $Q_LINK_FLAGS *.o -o libidx_sort.so
rm -f *.o
rm -f _x
cd -
echo "ALL DONE"
