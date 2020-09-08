#!/bin/bash
set -e 
#--- for ispc
cd
git clone https://github.com/ispc/ispc.git ispc
cd ispc
export ISPC_HOME=$PWD
export LLVM_HOME=$PWD
python3 alloy.py -b --version=10.0 --selfbuild
#--- for curl 
rm -r -f /tmp/curl/ \
 && cd /tmp/ \
 && git clone https://github.com/curl/curl.git \
 && cd /tmp/curl/ \
 && ./buildconf \
 && ./configure \
 && make \
 && make install

wget -O /tmp/lua-5.1.5.tar.gz "https://www.lua.org/ftp/lua-5.1.5.tar.gz" \
&& cd /tmp/  \
&& echo "2e115fe26e435e33b0d5c022e4490567 lua-5.1.5.tar.gz" | md5sum -c - \
&& mkdir -p /tmp/lua/ \
&& tar -zxvf /tmp/lua-5.1.5.tar.gz -C /tmp/lua/ --strip-components=1 \
&& cd /tmp/lua/ \
&& make linux \
&& make install \
&& rm -rf /tmp/lua*gz /tmp/lua/

## libevent
wget -O /tmp/libevent.tar.gz "https://github.com/libevent/libevent/releases/download/release-2.1.11-stable/libevent-2.1.11-stable.tar.gz" \
 &&  cd /tmp/ \
 &&  mkdir -p /tmp/libevent/ \
 &&  tar -zxf /tmp/libevent.tar.gz -C /tmp/libevent/ --strip-components=1  \
 &&  cd /tmp/libevent/ \
 &&  ./configure  \
 &&  make  \
 &&  make install  \
 &&  rm -rf /tmp/libevent.tar.gz  \
 &&  rm -rf /tmp/libevent/ 

## LuaJIT
wget -O /tmp/LuaJIT-2.1.0-beta3.tar.gz "https://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz" \
 &&   cd /tmp \
 &&  echo "eae40bc29d06ee5e3078f9444fcea39b LuaJIT-2.1.0-beta3.tar.gz" | md5sum -c - \
 && mkdir -p /tmp/LuaJIT \
 &&  tar -zxvf /tmp/LuaJIT-2.1.0-beta3.tar.gz -C /tmp/LuaJIT --strip-components=1  \
 &&  cd /tmp/LuaJIT/ \
 &&  make  \
 &&  make install  \
 &&  ln -sf luajit-2.1.0-beta3 /usr/local/bin/luajit \
 &&  rm -rf /tmp/LuaJIT*gz /tmp/LuaJIT 

## For Q
mkdir -p $HOME/local/
mkdir -p $HOME/local/Q/
mkdir -p $HOME/local/Q/data/
mkdir -p $HOME/local/Q/include
mkdir -p $HOME/local/Q/lib/
mkdir -p $HOME/local/Q/meta/

## LuaFFI
## TODO Hard-coded location of TGZ file
## had to remove -Werror and change lua5.2 to lua5.1 in Makefile
test -f $HOME/Q/EXTERNAL/luaffi-master.tgz
cp $HOME/Q/EXTERNAL/luaffi-master.tgz /tmp/
cd /tmp/
tar -zxvf luaffi-master.tgz
cd luaffi-master
if [ "$Q_IS_ARM" == "true" ]; then 
  cp $Q_SRC_ROOT/EXTERNAL/call_arm.h /tmp/luaffi-master
fi
make posix
cp ffi.so $HOME/local/Q/lib/
# following to protect ffi.so from accidental deletion
cp -r /tmp/luaffi-master $HOME/local/Q/ 

### For bison for ispc
# wget http://ftp.gnu.org/gnu/bison/bison-3.7.tar.gz -O /tmp/bison.tar.gz
# cd /tmp/
# tar -zxvf bison.tar.gz
# cd /tmp/bison-3.7/
# ./configure
# make
# make install
# cd /tmp/
# rm -r -f bison-3.7*
#------------------------------------------------
# Install lua-simdjson from source
rm -r -f /tmp/simdjson/ 
git clone https://github.com/FourierTransformer/lua-simdjson 
cd /tmp/simdjson/ 
luarocks make lua-simdjson-scm-0.rockspec 
rm -r -f /tmp/simdjson/


echo "All done"

