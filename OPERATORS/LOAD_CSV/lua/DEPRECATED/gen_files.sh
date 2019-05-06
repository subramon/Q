#!/bin/bash
set -e 

INCS="-I. -I../gen_inc -I../../../UTILS/gen_inc/  -I../../../UTILS/inc/ "
rm -rf ../gen_inc ../gen_src 
mkdir ../gen_inc ../gen_src 

cd ../src/
bash gen_files.sh
cd -
# generate all primitives

lua gen_code_I.lua 
lua gen_code_F.lua 
# iterate over all generated code=> should compile without warnings
cd ../gen_src/
ls *c > _x
while read line; do
  gcc -c $QC_FLAGS $line \
    -I../gen_inc -I../../../UTILS/gen_inc/  -I../../../UTILS/inc/ 
done< _x
gcc ../gen_src/*.o ../src/*.o -shared -o libload_csv.so
# cleanup
rm -f *.o
rm -f _x
cd -
echo "ALL DONE; $0 in $PWD"
