#!/bin/bash
set -e 
# IMPORTANT
# q_rashmap.c should be in sync with q_rhashmap_tmpl.c in q_rhashamp repo
# q_rashmap.h should be in sync with q_rhashmap_tmpl.h in q_rhashamp repo
# q_rashmap_struct.h should be in sync with q_rhashmap_struct.tmpl.h in q_rhashamp repo
EXT_DIR=$HOME/WORK/rhashmap/src/
test -d $EXT_DIR
cp $EXT_DIR/q_rhashmap.tmpl.c         .
cp $EXT_DIR/q_rhashmap.tmpl.h         .

cp $EXT_DIR/q_rhashmap_mk_hash.tmpl.h .
cp $EXT_DIR/q_rhashmap_mk_hash.tmpl.c .

cp $EXT_DIR/q_rhashmap_mk_loc.c .
cp $EXT_DIR/q_rhashmap_mk_loc.h .

cp $EXT_DIR/q_rhashmap_mk_tid.c .
cp $EXT_DIR/q_rhashmap_mk_tid.h .

cp $EXT_DIR/q_rhashmap_struct.tmpl.h .
cp $EXT_DIR/q_rhashmap_common.h .

