#!/bin/bash
set -e
bash my_print.sh "STARTING: Installing luarocks"
LUAROCKS_VER=$(luarocks --version | awk '/luarocks/ {print $2;exit 0;}')
REQUIRED_LUAROCKS="2.4.2" #specify here the required luarocks version

if [ $LUAROCKS_VER == $REQUIRED_LUAROCKS ];then
  bash my_print.sh "LuaRocks $LUAROCKS_VER up to date with required version"
else
  #TODO: instead of wget we can get this tar from Q repo
  wget https://luarocks.org/releases/luarocks-2.4.1.tar.gz
  tar zxpf luarocks-2.4.1.tar.gz
  cd luarocks-2.4.1
  ./configure; sudo make bootstrap
  cd ../
  rm -rf luarocks-2.4.1
fi
bash my_print.sh "COMPLETED: Installing luarocks"


