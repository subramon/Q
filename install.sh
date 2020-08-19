#!/bin/bash
set -e
source setup.sh
bash packages.sh
bash lua_packages.sh
bash from_source.sh
cd $HOME/Q/UTILS/build/
make clean && make
luajit test_qd.lua
lua    test_qd.lua
echo "Q installed"
