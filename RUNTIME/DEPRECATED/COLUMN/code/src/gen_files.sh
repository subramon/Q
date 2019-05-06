#!/bin/bash
set -e 
UDIR=${Q_SRC_ROOT}/UTILS/lua
test -d $UDIR
rm -f ../gen_inc/*.h
# luajit $UDIR/extract_func_decl.lua vector_mmap.c ../gen_inc/
# luajit $UDIR/extract_func_decl.lua vector_munmap.c ../gen_inc/
echo "Completed $0 in $PWD"
