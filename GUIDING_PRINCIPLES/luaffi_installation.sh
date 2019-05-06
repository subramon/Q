#!/bin/bash
set -e
bash my_print.sh "STARTING: Installing luaffi"
git clone https://github.com/jmckaskill/luaffi.git
cd luaffi
make
# EX_PATH=`echo $LUA_CPATH | awk -F'/' 'BEGIN{OFS=FS} {$NF=""; print $0}'`;
EX_PATH="${Q_ROOT}/lib"
echo $EX_PATH
cp ffi.so $EX_PATH
rm -f /tmp/ffi.so
#copying the ffi.so to /tmp/ as we require this later &
#at end of this script we are deleting the luaffi directory.
cp ffi.so /tmp/
cd ../
sudo rm -rf luaffi
bash my_print.sh "COMPLETED: Installing luaffi"
