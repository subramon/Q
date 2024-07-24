#!/bin/bash
set -e 
cd ../src/
export LD_LIBRARY_PATH=$PWD:$LD_LIBRARY_PATH
export PATH=$PATH:$PWD
#-------------------------
valgrind --leak-check=full --show-leak-kinds=all ut1 1>_x 2>&1
grep 'definitely lost: 0 bytes in 0 blocks' _x

valgrind --leak-check=full --show-leak-kinds=all ut2 1>_x 2>&1
grep 'definitely lost: 0 bytes in 0 blocks' _x

valgrind --leak-check=full --show-leak-kinds=all ut_memo 1>_x 2>&1
grep 'definitely lost: 0 bytes in 0 blocks' _x
#-------------------------
cd -
cd Lua/
bash run_lua.sh
cd -
echo "Successfully completed $0 in $PWD"
