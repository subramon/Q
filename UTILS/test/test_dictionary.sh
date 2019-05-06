#!/bin/bash 
set -e 

luajit -lluacov test_dictionary.lua $1
luacov
