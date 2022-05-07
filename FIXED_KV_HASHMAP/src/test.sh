#!/bin/bash
set -e
rm -f ./test
ispc   m_fasthash.c  -h m_fasthash.h
ispc -O3 --pic  m_fasthash.c  -o m_fasthash.o
gcc  -O4 -c fasthash.c -o fasthash.o -I../inc/
gcc  -O4 -c d.c -o d.o -I../inc/

gcc d.o m_fasthash.o fasthash.o -o test
echo "Compiled"
./test
echo "Done"
