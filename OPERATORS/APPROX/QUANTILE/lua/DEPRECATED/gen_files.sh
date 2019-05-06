#!/bin/bash
set -r
luajit generator.lua
echo "Successfully completed $0 in $PWD"
