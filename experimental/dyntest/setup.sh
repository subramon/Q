#!/bin/bash
tar -xvzf lua-5.3.3.tar.gz
cd lua-5.3.3/
sed -ri 's/MYCFLAGS=/MYCFLAGS= -fPIC/' src/Makefile
make linux
cd ../
tar -xvzf dyncall-0.9.tar.gz
cd ./dyncall-0.9/
./configure
make
sudo make install
cd ../
tar -xvzf luaffi
cd luaffi
make
cd ../
tar -xvzf bindings.tar.gz
cd ./bindings/lua/luadc/
make
cd testFuncs/
gcc -shared -fPIC -o libtest.so test.c
gcc mylib.c -shared -o mylib.so -fPIC
echo "*********lua c api**********"
lua luactest5.lua
echo "*********luajit c api**********"
lua luactest5.lua

echo "*********Lua with dyncall*****"
# ../../../../lua-5.3.3/src/lua dctest.lua
# ../../../../lua-5.3.3/src/lua dctest2.lua
# ../../../../lua-5.3.3/src/lua dctest3.lua
# ../../../../lua-5.3.3/src/lua dctest4.lua
../../../../lua-5.3.3/src/lua dctest5.lua

cp ../../../../luaffi/ffi.so ./
echo "*****lua + ffi *****"
# lua ffitest.lua
# lua ffitest2.lua
# lua ffitest3.lua
# lua ffitest4.lua
lua ffitest5.lua
echo "*****luajit *****"
luajit ffitest5.lua


cd ../../../
# Note that the make here is modified to have fPIC in luajit a dyncall
# requirement
tar -xvzf LuaJIT-2.1.0-beta3.tar.gz
cd LuaJIT-2.1.0-beta3/
make
cd ../bindings/luajit/luadc/
make
cd testFuncs
echo "*********Luajit with dyncall*****"
# ../../../../LuaJIT-2.1.0-beta3/src/luajit dctest.lua
# ../../../../LuaJIT-2.1.0-beta3/src/luajit dctest2.lua
# ../../../../LuaJIT-2.1.0-beta3/src/luajit dctest3.lua
# ../../../../LuaJIT-2.1.0-beta3/src/luajit dctest4.lua
../../../../LuaJIT-2.1.0-beta3/src/luajit dctest5.lua

# echo "*****luajit *****"
# luajit ffitest.lua
# luajit ffitest2.lua
# luajit ffitest3.lua
# luajit ffitest4.lua

