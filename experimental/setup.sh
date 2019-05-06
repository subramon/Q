#!/bin/bash
#hg clone http://hg.dyncall.org/pub/dyncall/dyncall
cd dyncall
./configure
make
make install
cd ../
#hg clone http://hg.dyncall.org/pub/dyncall/bindings
cd bindings/lua/luadc

