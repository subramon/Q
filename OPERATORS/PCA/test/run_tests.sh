#!/bin/bash
set -e 
rm -f _*
make -C ../src/ clean
make -C ../src/ 
luajit test_eigen.lua "true"
luajit test_eigen.lua "false"
luajit test_pca.lua
# luajit test_corrm.lua
echo "Successfully completed $0 in $PWD"
rm -f _*
