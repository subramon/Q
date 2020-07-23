#!/bin/bash
set -e
bash packages.sh
bash lua_packages.sh
bash from_source.sh
cd $HOME/Q/UTILS/build/
make clean
make
echo "Q installed"
