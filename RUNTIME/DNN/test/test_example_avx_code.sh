#!/bin/bash
set -e 
gcc -O4 -mavx example_avx_code.c -D__INTEL_COMPILER -o example_avx
./example_avx
echo "Success for $0 in $PWD"
rm -f ./example_avx
