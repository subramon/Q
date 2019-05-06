#!/bin/bash 
set -e 

luajit test_load.lua meta.lua test.csv
echo "Completed $0 in $PWD"
