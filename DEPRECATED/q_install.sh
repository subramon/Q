#!/bin/bash
source ./setup.sh

# Cleanup
rm -rf /usr/local/share/lua/5.1/Q

rm -rf /usr/lib/libq_core.so
rm -rf /usr/local/lib/lua/5.1/libcmem.so
rm -rf /usr/local/lib/lua/5.1/libsclr.so
rm -rf /usr/local/lib/lua/5.1/libvec.so

rm -rf /usr/local/share/lua/5.1/Q/q_core.h

# Install
mkdir /usr/local/share/lua/5.1/Q
cp -r ./OPERATORS /usr/local/share/lua/5.1/Q
cp -r ./UTILS /usr/local/share/lua/5.1/Q
cp -r ./RUNTIME /usr/local/share/lua/5.1/Q
cp -r ./ML /usr/local/share/lua/5.1/Q
cp -r  q_export.lua /usr/local/share/lua/5.1/Q
cp -r  init.lua /usr/local/share/lua/5.1/Q

# FIX THIS, pick library from build target
cp $Q_ROOT/lib/libq_core.so /usr/lib/
cp $Q_ROOT/lib/libcmem.so /usr/local/lib/lua/5.1/
cp $Q_ROOT/lib/libsclr.so /usr/local/lib/lua/5.1/
cp $Q_ROOT/lib/libvec.so /usr/local/lib/lua/5.1/
cp $Q_ROOT/include/q_core.h /usr/local/share/lua/5.1/Q

# TODO copy over terra.so (from TERRA_HOME?) to /usr/local/lib/lua/5.1/terra.so
