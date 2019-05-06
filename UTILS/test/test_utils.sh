#!/bin/bash 
set -e 

luajit -lluacov test_utils.lua $1
luacov
