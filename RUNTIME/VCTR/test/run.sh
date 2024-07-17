#!/bin/bash
set -e 
cd ../src/
export LD_LIBRARY_PATH=$PWD:$LD_LIBRARY_PATH
./ut1
./ut2
./ut_memo
cd -
cd Lua/
bash run_lua.sh
cd -
echo "Successfully completed $0 in $PWD"
