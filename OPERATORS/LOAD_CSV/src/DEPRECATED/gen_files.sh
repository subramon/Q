#!/bin/bash
set -e 
# TODO. Don't want to have to provide path for Lua utilities
test -d "$Q_SRC_ROOT"
UDIR="$Q_SRC_ROOT/UTILS/lua"
test -d $UDIR

cd $Q_SRC_ROOT/UTILS/src/
bash gen_files.sh
cd -
#TODO P4 Improve this
lua $UDIR/cli_extract_func_decl.lua get_cell.c ../gen_inc/
lua $UDIR/cli_extract_func_decl.lua txt_to_SC.c ../gen_inc/

INCS="-I$Q_SRC_ROOT/UTILS/inc/ -I$Q_SRC_ROOT/UTILS/gen_inc/ -I../gen_inc"

gcc -c $QC_FLAGS get_cell.c $INCS
gcc -c $QC_FLAGS txt_to_SC.c $INCS
echo "ALL DONE $0 in $PWD"
