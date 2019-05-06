#!/bin/bash
luajit $Q_SRC_ROOT/RUNTIME/test/lVector_test/test_lVector.lua

# Revert the modified bin files
git checkout $Q_SRC_ROOT/RUNTIME/test/lVector_test/bin/

# Clean temporary files
rm -f _*
