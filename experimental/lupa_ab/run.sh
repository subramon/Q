#!/bin/bash
set -e
rm -f ./ut_ab lib_ab.so
gcc -g -std=gnu99 -shared -fPIC core.c -o lib_ab.so
gcc -g -std=gnu99 -fPIC core.c -o ut_ab
valgrind ./ut_ab
rm -f ./ut_ab

echo "Created lib_ab.so"
