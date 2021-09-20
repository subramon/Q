#!/bin/bash
ispc -O3 --pic reorder_isp.c -o reorder_isp.o 
gcc -O4 stand_alone.c reorder.c get_time_usec.c preproc_j.c \
  reorder_isp.o \
  -lpthread -o test
N=8388608 # length of atrray being resorted
P=1 # number of threads. Set to 1 for now
mode="scalar"
./test $N $P $mode
mode="vector"
./test $N $P $mode
