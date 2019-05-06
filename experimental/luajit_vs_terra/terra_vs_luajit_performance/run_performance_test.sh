#!/bin/bash
set -e
if [ ${#} -ne 2 ]
then
  echo "Usage: bash run_performance_test.sh <terra/luajit/luaterra> <input_csv_path>"
  exit 1
fi

export Q_ROOT="."
export LUA_PATH=";./lua/column_lua/?.lua;./lua/utils_lua/?.lua;./lua/?.lua;;"
export LUA_PATH="$LUA_PATH;./lua/load_csv_lua/?.lua"

unset LD_LIBRARY_PATH
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:./lib"

echo "--------------------------------------------"
echo "Running Perfromance Test"
echo "--------------------------------------------"

compiler=$(echo $1 | tr '[:upper:]' '[:lower:]')

if [ ! \( \( $compiler == "terra" \) -o \( $compiler == "luajit" \) -o \( $compiler == "luaterra" \) \) ]
then
  echo "First argument is incorrect, available options are : {terra, luajit, luaterra}"
  exit 1
fi

use_terra=false
if [ $compiler == "luaterra" ]
then
  use_terra=true
  # Using luajit compiler as luajit-2.0.4 instead of luajit-2.1.0-beta3 
  # as we are facing issue with newer compiler when introduced the require 'terra' statement
  compiler=luajit-2.0.4
elif [ $compiler == "luajit" ]
then
  compiler=luajit-2.0.4
fi

$compiler lua/test_performance.lua $2 $use_terra

echo "DONE"


