#!/bin/bash
# save original config file 
cp ~/local/Q/config/q_config.lua save_config.lua
# make new directories
test -d "$Q_SRC_ROOT"
datadir="$Q_SRC_ROOT/RUNTIME/VCTR/test/TEST_IMPORT/data"
metadir="$Q_SRC_ROOT/RUNTIME/VCTR/test/TEST_IMPORT/meta"
rm -r -f $datadir
rm -r -f $metadir
mkdir -p $datadir
mkdir -p $metadir
#---------------------------------------------------
# overwrite with custom config file 
cp q_config.lua ~/local/Q/config/q_config.lua 
# make the data and save it 
qjit make_data.lua
# restore original config file 
cp save_config.lua ~/local/Q/config/q_config.lua 
rm save_config.lua

echo "ALL DONE"
