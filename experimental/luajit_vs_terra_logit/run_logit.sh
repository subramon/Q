#!/bin/bash
set -e
if [ ${#} -ne 2 ]
then
  echo "Usage: bash run_performance_test.sh <luajit-2.1.0-beta3/luajit-2.0.4> <use_terra(true/false)>"
  exit 1
fi

compiler=$(echo $1 | tr '[:upper:]' '[:lower:]')

if [ ! \( \( $compiler == "luajit-2.1.0-beta3" \) -o \( $compiler == "luajit-2.0.4" \) \) ]
then
  echo "First argument is incorrect, available options are : {luajit-2.1.0-beta3, luajit-2.0.4}"
  exit 1
fi

use_terra=$2
#if [ \( $compiler == "luajit-2.1.0-beta3" \) -a \( $use_terra == "true" \) ]
#then
  #as we are facing issue with luajit-2.1.0-beta3 compiler when introduced the require 'terra' statement
  # Issue is: luajit-2.1.0-beta3: strict.lua: cannot load incompatible bytecode
#  echo "Running test without terra: As luajit-2.1.0-beta3 version is facing issue with terra"
#  use_terra=false
#fi

$compiler test_logit_terra.lua $use_terra

echo "DONE"


