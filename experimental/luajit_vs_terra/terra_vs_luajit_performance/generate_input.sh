#!/bin/bash
set -e
if [ ${#} -ne 3 ]
then
  echo "Usage: bash generate_input.sh <terra/luajit> <output_csv_path> <row_count>"
  exit 1
fi

export Q_ROOT="."
export LUA_PATH=";./lua/column_lua/?.lua;./lua/utils_lua/?.lua;./lua/?.lua;;"
export LUA_PATH="$LUA_PATH;./lua/load_csv_lua/?.lua"

unset LD_LIBRARY_PATH
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:./lib"

echo "--------------------------------------------"
echo "Generating Test Input Files"
echo "--------------------------------------------"

compiler=$(echo $1 | tr '[:upper:]' '[:lower:]')
$compiler lua/generate_input.lua $2 $3

echo "DONE"


