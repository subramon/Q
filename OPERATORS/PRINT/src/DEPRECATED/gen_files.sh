#!/bin/bash
set -e 
# TODO. Don't want to have to provide path for Lua utilities
UDIR=${Q_SRC_ROOT}/UTILS/lua
test -d $UDIR
lua $UDIR/extract_func_decl.lua SC_to_txt.c ../gen_inc/
echo "ALL DONE $0 in $PWD"
