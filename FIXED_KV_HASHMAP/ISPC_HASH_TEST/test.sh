#!/bin/bash
set -e
rm -f ./test
# ispc   m_fasthash.c  -h m_fasthash.h
# ispc -O3 --pic  m_fasthash.c  -o m_fasthash.o
gcc  -g -c fasthash.c -o fasthash.o 
gcc  -g -c d.c -o d.o 

# gcc d.o m_fasthash.o fasthash.o -o test
gcc d.o fasthash.o -o test
echo "Compiled"
./test
echo "Done"
