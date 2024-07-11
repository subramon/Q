#!/bin/bash
set -e
mkdir -p $Q_ROOT/
mkdir -p $Q_ROOT/lib/
mkdir -p $Q_ROOT/bin/
mkdir -p $Q_ROOT/config/
mkdir -p $Q_ROOT/csos/
mkdir -p $Q_ROOT/cdefs/

test -d $Q_ROOT/
test -d $Q_ROOT/lib/
test -d $Q_ROOT/bin/
test -d $Q_ROOT/config/
test -d $Q_ROOT/csos/
test -d $Q_ROOT/cdefs/

test -d $RSUTILS_SRC_ROOT
test -d $RSHMAP_SRC_ROOT
#-----------------------------------
echo "Tested environment variables for Q"
#-- TODO Put in more tests here
