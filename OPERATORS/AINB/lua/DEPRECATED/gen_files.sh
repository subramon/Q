#!/bin/bash
INCS=" -I../gen_inc -I../../../UTILS/gen_inc/ -I../../../UTILS/inc/ "
set -e 
rm -r -f ../gen_src/; mkdir ../gen_src/
rm -r -f ../gen_inc/; mkdir ../gen_inc/
lua generator.lua 

cd ../../../UTILS/src/
bash gen_files.sh
cd -

cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $line $QC_FLAGS $INCS 
done< _x
echo "Done compiling"
gcc $Q_LINK_FLAGS *.o -o libainb.so
rm -f *.o *
rm -f _x
cd -
lua pkg_ainb.lua
test -f _ainb.lua
echo "ALL DONE: $0 in $PWD"
