#!/bin/bash
set -e 
infile="$1"
test -f $infile
if [ $# == 2 ]; then 
  str="$2"
else
  str="wms"
fi
gcc -O4 -std=gnu99 fasthash.c -shared -o libfasthash.so
# inside Lua ispc str_in_set.ispc -h str_in_set_ispc.h
# inside Lua ispc str_in_set.ispc -o str_in_set_ispc.o
# inside Lua gcc -g -c str_in_set.c -o str_in_set.o
# inside Lua gcc -g -c fasthash.c
# inside Lua gcc fasthash.o str_in_set.o str_in_set_ispc.o -shared -o libstr_in_set.so
#-- finished compiling 
lua driver.lua $infile ${str}

echo "All done"
