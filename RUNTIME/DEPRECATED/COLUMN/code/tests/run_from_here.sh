#!/bin/bash
cd ../
make
make test
cp test*.txt *_nn ./tests/
cd tests
LD_LIBRARY_PATH="../" LUA_PATH="../?.lua" luajit-2.0.4 ../testVector.lua
rm *.txt *_nn
