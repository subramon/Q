#!/bin/bash
set -e 

rm -rf metadata/
mkdir metadata

luajit test_meta_data.lua $1

echo "Completed $0 in $PWD"

