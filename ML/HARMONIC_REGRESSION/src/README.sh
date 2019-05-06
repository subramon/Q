##/bin/bash
set -e
gcc -g -std=gnu99 ../../../UTILS/src/mmap.c hr.c \
  ../../../AxEqualsBSolver/aux_driver.c \
  ../../../AxEqualsBSolver/positive_solver.c \
  -I../../../UTILS/inc \
  -I../../../AxEqualsBSolver/ \
  -o hr -lm 

# ./hr <INPUT FILE> <OUTPUT FILE> <PERIOD>
# Values for PERIOD are 7, 14, ...
inputfile=../data/harm_reg.csv
outputfile=_out.csv
period=7 # experiment with 7, 14, 28, ....
./hr $inputfile $outputfile $period
