#!/bin/bash
gcc -g -std=gnu99 driver.c qsort2.c qsort2_asc_I4.c -I.

./a.out

rm a.out
