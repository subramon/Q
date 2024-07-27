#!/bin/bash
set -e 
mkdir -p $PWD/data/
mkdir -p $PWD/meta/
qjit --config $PWD/conf1.lua  make_some_vecs.lua 
echo "Create a vector x"
qjit --config $PWD/conf2.lua  restore_stuff.lua 
echo "Restored a vector x"
echo "Completed $0 in $PWD"
rm -rf  $PWD/data/
rm -rf  $PWD/meta/
