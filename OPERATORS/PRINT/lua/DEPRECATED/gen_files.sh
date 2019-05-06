#!/bin/bash
set -e 

rm -rf ../gen_inc ; mkdir -p ../gen_inc 
mkdir -p ../gen_src ; rm -rf ../gen_src 

INCS="-I../gen_inc -I../../../UTILS/inc/ "
UDIR=../../../UTILS/lua/
test -f $UDIR/cli_extract_func_decl.lua
lua $UDIR/cli_extract_func_decl.lua ../src/SC_to_txt.c ../gen_inc/
lua generator.lua 
#----------------------
cd ../src/
gcc -c $QC_FLAGS SC_to_txt.c $INCS
#----------------------
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $line ${QC_FLAGS} $INCS
done< _x
#----------------------
gcc $Q_LINK_FLAGS ../gen_src/*.o ../src/*.o -o libprint.so
rm -f *.o
rm -f _x
cd -
#-------------------------
echo "ALL DONE; $0 in $PWD"
