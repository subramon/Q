#!/bin/bash
set -e 
# START: Create a tablespace with a single vector "x"
mkdir -p $PWD/data/
mkdir -p $PWD/meta/
qjit --config $PWD/conf1.lua  make_some_vecs.lua 
#-- Create another tablespace with a single vector "x" 
mkdir -p $PWD/data_import/
mkdir -p $PWD/meta_import/
qjit --config $PWD/conf_import_1.lua  make_some_vecs.lua 
#--- 
# Import first tablespace into second and check 
qjit --config $PWD/conf_import_2.lua  test_import.lua 

# TODO Use stuff form ../test_import.lua
echo "Completed $0 in $PWD"
rm -rf  $PWD/data/
rm -rf  $PWD/meta/
rm -rf $PWD/data_import/
rm -rf $PWD/meta_imt port/
