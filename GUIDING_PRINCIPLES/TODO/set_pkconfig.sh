#!/bin/bash
set -e
bash my_print.sh "STARTING: Installing lua from source"
#TODO:version checking
#LUA_VER=$(lua -v)
#REQUIRED_LUA="Lua 5.1.5  Copyright (C) 1994-2012 Lua.org, PUC-Rio" #specify here the required lua version

#TODO: instead of wget we can get this tar from Q repo
wget https://www.lua.org/ftp/lua-5.1.5.tar.gz
tar -xvzf lua-5.1.5.tar.gz
cd lua-5.1.5/

IS_LUA_DEBUG=$1
#debug flag is set then append the -g flag
if [ "$#" -eq 1 -a $IS_LUA_DEBUG == "LUA_DEBUG" ];then
  sed -i '11s/CFLAGS=/CFLAGS= -g/' src/Makefile
fi

make linux
sudo make install

#debug flag is set then creating a link to L
if [ "$#" -eq 1 -a $IS_LUA_DEBUG == "LUA_DEBUG" ];then
  sudo ln -sf /usr/local/bin/lua /usr/local/bin/L
  #TODO: temporary hack: by creating a link 'luajit' which points to lua
  #our Q build(Makefiles) is using luajit as interpreter, so pointing luajit to lua. Need to discuss.
  sudo ln -sf /usr/local/bin/lua /usr/local/bin/luajit
fi

## adding temporary hack for checking pkgconfig location
if [[ -d /usr/lib/pkgconfig ]]; then
  sudo cp ./etc/lua.pc /usr/lib/pkgconfig
elif [[ -d /usr/share/pkgconfig ]]; then
  sudo cp ./etc/lua.pc /usr/share/pkgconfig
elif [[ -d /usr/local/lib/pkgconfig ]]; then
  sudo cp ./etc/lua.pc /usr/local/lib/pkgconfig
elif [[ -d /usr/local/share/pkgconfig ]]; then
  sudo cp ./etc/lua.pc /usr/local/share/pkgconfig
fi

cd ../
rm -rf lua-5.1.5 lua-5.1.5.tar.gz
bash my_print.sh "COMPLETED: Installing lua from source"
