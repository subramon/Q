#!/bin/bash 
set -e
# simple test to print 5 I4 values = [1,2,3,4,5] and SV values mapped to I4 values
# from the bin file I4.bin in bin folder.
# output should print the I4 values and the SV values
luajit test_print.lua
echo "Completed $0 in $PWD"
