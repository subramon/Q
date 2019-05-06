#!/bin/bash
set -e 
# TODO. Don't want to have to provide path for Lua utilities
test -d "$Q_SRC_ROOT"
UDIR="$Q_SRC_ROOT/UTILS/lua"
test -d $UDIR
lua $UDIR/extract_func_decl.lua txt_to_SC.c ../gen_inc/
lua $UDIR/extract_func_decl.lua get_cell.c ../gen_inc/
echo "ALL DONE $0 in $PWD"
