#!/bin/bash 
set -e
luajit -lluacov test_load_csv.lua $1
luacov
