#!/bin/bash
set -e
if [ $# != 3 ]; then 
  echo "Usage is <pattern> <infile> <outfile>"; exit 1;
fi
if [ "$Q_SRC_ROOT" == "" ]; then echo "Set Q_SRC_ROOT"; exit 1; fi 
luajit $Q_SRC_ROOT/UTILS/lua/subs_tmpl.lua $1 $2 $3

