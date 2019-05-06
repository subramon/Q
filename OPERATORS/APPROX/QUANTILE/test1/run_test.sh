#!/bin/bash
set -e
FILES="testApproxQuantile.c "
USEGEN=1
if [ $USEGEN = 1 ]; then 
  FILES="${FILES} ../gen_src/_approx_quantile_I4.c"
  FILES="${FILES} ../gen_src/_Collapse_I4.c"
  FILES="${FILES} ../gen_src/_New_I4.c"
  FILES="${FILES} ../gen_src/_Output_I4.c"
  FILES="${FILES} ../src/determine_b_k.c"
else
  FILES="${FILES} approx_quantile.c"
  FILES="${FILES} Collapse.c"
  FILES="${FILES} New.c"
  FILES="${FILES} Output.c"
  FILES="${FILES} determine_b_k.c"
fi
FILES="${FILES} rs_mmap.c"
FILES="${FILES} qsort_asc_I4.c"

INCS=" -I. -I../gen_inc/ -I../../../../UTILS/inc/ -I../src/"

FLAGS=' -std=gnu99 -Wall'

OUTPUT='aq'

gcc -g ${FILES} ${INCS} ${FLAGS} -o $OUTPUT -lm

# A. Run some R program with inputs 
#   (1) number of elements 
#   (2) distribution parameters 
#   to create a CSV file
# B. Run asc2bin to convert  CSV to binary
# C. ./aq foo.bin
# D. Verify outputs

echo "Successfully completed $0 in $PWD"
