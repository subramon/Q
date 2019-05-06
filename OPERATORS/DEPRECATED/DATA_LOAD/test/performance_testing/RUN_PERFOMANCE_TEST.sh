#!/bin/bash
set -e

echo "-----------------------------"
echo "Running Perfomance Test Cases"
echo "-----------------------------"
luajit test_performance.lua 

echo "DONE"


