#!/bin/bash
set -e 

rm -rf ../gen_inc ../gen_src
mkdir ../gen_inc ../gen_src

# generate all primitives
lua gen_code_I.lua 
lua gen_code_F.lua 
# iterate over all generated code=> should compile without warnings
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $line \
    -I../gen_inc -I../../../UTILS/gen_inc/  -I../../../UTILS/inc/ 
done< _x
# cleanup
rm -f *.o
rm -f _x
cd -
echo "ALL DONE; $0 in $PWD"
