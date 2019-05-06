#!/bin/bash
COLOR_RED='\e[0;91m'
COLOR_GREEN='\e[0;92m'
COLOR_NORMAL='\e[0m'
my_print(){
  if [ -z "$2" ] ; then
    echo -e "$COLOR_GREEN AIO: $1 $COLOR_NORMAL"
  else
    echo -e "$COLOR_RED AIO: $1 $COLOR_NORMAL"
  fi
}

cleanup(){
  if [ -z "$1" ]; then
    my_print "No directory passed to cleanup" 1
    exit 1
  fi
  my_print $1
  find $1 -name "*.o" -o -name "_*" | xargs rm
}

install_apt_get_dependencies(){
  my_print "Installing dependencies from apt-get"
  sudo apt-get update
  sudo apt-get install make cmake -y
  sudo apt-get install unzip -y # for luarocks
  sudo apt-get install libncurses5-dev -y # for lua-5.1.5
  sudo apt-get install libssl-dev -y # for QLI
  sudo apt-get install m4 -y         # for QLI
  sudo apt-get install libreadline-dev -y 
}

install_lua_from_apt_get(){
  my_print "Installing lua from apt-get"
  sudo apt-get install lua5.1 -y
  sudo apt-get install liblua5.1-dev -y
}

install_lua_from_source(){
  my_print "Installing lua from source"
  wget https://www.lua.org/ftp/lua-5.1.5.tar.gz
  tar -xvzf lua-5.1.5.tar.gz
  cd lua-5.1.5/
  make linux
  sudo make install
  sudo cp ./etc/lua.pc /usr/lib/pkgconfig/
  cd ../
  rm -rf lua-5.1.5 lua-5.1.5.tar.gz

}

install_luajit_from_source() {
  my_print "Installing luajit from source"
  #wget http://luajit.org/download/LuaJIT-2.0.4.tar.gz
  wget http://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz
  #tar -xvf LuaJIT-2.0.4.tar.gz
  tar -xvf LuaJIT-2.1.0-beta3.tar.gz
  #cd LuaJIT-2.0.4/
  cd LuaJIT-2.1.0-beta3/
  sed -i '114s/#//' src/Makefile # to enable gc64
  make TARGET_FLAGS=-pthread
  sudo make install
  cd /usr/local/bin
  sudo ln -sf luajit-2.1.0-beta3 /usr/local/bin/L
  sudo ln -sf luajit-2.1.0-beta3 /usr/local/bin/luajit

  cd -
  cd ../
  rm -rf LuaJIT-2.1.0-beta3
}

install_luarocks_from_source(){
  my_print "Installing lua rocks"
  wget https://luarocks.org/releases/luarocks-2.4.1.tar.gz
  tar zxpf luarocks-2.4.1.tar.gz
  cd luarocks-2.4.1
  ./configure; sudo make bootstrap
  cd ../
  rm -rf luarocks-2.4.1
}

install_luarocks_dependencies(){
  my_print "Installing dependencies using luarocks"
  sudo luarocks install penlight
  sudo luarocks install luaposix
  sudo luarocks install luv
  sudo luarocks install busted
  sudo luarocks install luacov
  sudo luarocks install cluacov
  sudo luarocks install http      # for QLI
  sudo luarocks install linenoise # for QLI

}

install_luaffi(){
  my_print "Installing luaffi"
  git clone https://github.com/jmckaskill/luaffi.git
  cd luaffi
  make
  # EX_PATH=`echo $LUA_CPATH | awk -F'/' 'BEGIN{OFS=FS} {$NF=""; print $0}'`;
  EX_PATH="${Q_ROOT}/lib"
  echo $EX_PATH
  cp ffi.so $EX_PATH
  cd ../
  sudo rm -rf luaffi

}

install_debug_lua_from_source(){
  my_print "Installing lua with -g flag"
  wget https://www.lua.org/ftp/lua-5.1.5.tar.gz
  tar -xvzf ./lua-5.1.5.tar.gz
  cd lua-5.1.5/
  # sed -i '17s/MYCFLAGS=/MYCFLAGS= -g/' src/Makefile
  # sed -i '99s/MYFLAGS=/MYFLAGS=-g /' src/Makefile
  sed -i '11s/CFLAGS=/CFLAGS= -g/' src/Makefile
  make linux
  sudo make install
  sudo ln -sf /usr/local/bin/lua /usr/local/bin/L
  sudo cp ./etc/lua.pc /usr/lib/pkgconfig/
  cd ../
  sudo rm -rf lua-5.1.5

}

clean_q(){
  my_print "Cleaning Q"
  cd ../UTILS/build
  make clean
  cd -
}

build_q(){
  my_print "Building Q"
  cd ../UTILS/build
  make all
  cd -
}

run_q_tests(){
  PROG_START="
  q_core = require 'Q/UTILS/lua/q_core'
  require 'globals'
  load_csv = require 'load_csv'
  print_csv = require 'print_csv'
  mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
  save = require 'Q/UTILS/lua/save'
  "
  PROG_SAVE="
  local q_core = require 'Q/UTILS/lua/q_core'
  local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
  local save = require 'Q/UTILS/lua/save'
  x = mk_col({10, 20, 30, 40}, 'I4')
  print(type(x))
  print(x:length())
  save('tmp.save')
  "
  PROG_RESTORE="
  dofile(os.getenv('Q_METADATA_DIR') .. '/tmp.save')
  print(type(x))
  print(x:length())
  print_csv = require 'Q/OPERATORS/PRINT/lua/print_csv'
  print_csv(x)
  "

  # performance test stretch goal - add
  luajit -e "$PROG" &>/dev/null
  RES=$?
  if [[ $RES -eq 0 ]] ; then
    my_print "SUCCESS in loading all libs"
  else
    my_print "FAIL" "error"
  fi

  luajit -e "$PROG_SAVE"
  RES=$?
  if [[ $RES -eq 0 ]] ; then
    my_print "SUCCESS in saving"
  else
    my_print "FAIL" "error"
  fi

  luajit -e "$PROG_RESTORE"
  RES=$?
  if [[ $RES -eq 0 ]] ; then
    my_print "SUCCESS in restoring"
  else
    my_print "FAIL" "error"
  fi
}


my_print "Stating the all in one script"
source ../setup.sh
while getopts 'hd' opt;
do
  case $opt in
    h)
      exit 0
      ;;
    d)
      export QC_FLAGS="$QC_FLAGS -g"
      LUA_DEBUG=1
  esac
done



install_apt_get_dependencies
# install_lua_from_apt_get
if [ $LUA_DEBUG -eq 1 ]
then
  install_debug_lua_from_source
  #install_luaffi
else
  install_lua_from_source
  install_luajit_from_source
fi

echo "`whoami` hard nofile 102400" | sudo tee --append /etc/security/limits.conf
echo "`whoami` soft nofile 102400" | sudo tee --append /etc/security/limits.conf

# ######## Luarocks #########
which luarocks &> /dev/null
RES=$?
if [[ $RES -ne 0 ]] ; then
  install_luarocks_from_source
  install_luarocks_dependencies
else
  my_print "luarocks is already installed"
fi

# ######## Install LAPACK stuff #######
sudo apt-get install liblapacke-dev liblapack-dev -y

#  ######## Build Q #########
my_print "Building Q"
cleanup ../ #cleaning up all files
clean_q
if [ $LUA_DEBUG ]; then 
  install_luaffi
fi
build_q
run_q_tests
#
echo "Successfully completed $0 in $PWD"
