#!/bin/bash
mkdir -p lib
rm -f lib/libq_core.so

gcc -g -std=gnu99 -Wall -fPIC -W -Waggregate-return \
  -Wcast-align -Wmissing-prototypes -Wnested-externs \
  -Wshadow -Wwrite-strings -pedantic -fopenmp \
  c/* \
  -I./inc/ \
  -shared -o lib/libq_core.so

status=$?
echo "================================================"

if [ $status == 0 ]
then
   echo "Created lib at ./lib/libq_core.so"
else
   echo "Failed to create library"
fi
