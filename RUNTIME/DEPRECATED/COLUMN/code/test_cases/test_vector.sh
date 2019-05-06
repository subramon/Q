#!/bin/bash 
set -e 

luajit -lluacov test_vector.lua $1
luacov
echo "Completed $0 in $PWD"
