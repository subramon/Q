#!/bin/bash 
set -e
rm -rf test_print_data

luajit -lluacov test_print_csv.lua $1
luacov

