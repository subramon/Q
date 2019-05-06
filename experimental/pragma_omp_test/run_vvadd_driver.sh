#!/bin/bash

gcc -O4 $QC_FLAGS $Q_SRC_ROOT/experimental/pragma_omp_test/vvadd_driver.c \
  $Q_SRC_ROOT/experimental/pragma_omp_test/vvadd_I4_I4_I4.c \
  $Q_SRC_ROOT/UTILS/src/get_time_usec.c \
  -I$Q_SRC_ROOT/experimental/pragma_omp_test/ \
  -I$Q_SRC_ROOT/UTILS/inc/ \
  -I$Q_SRC_ROOT/UTILS/gen_inc/ -lgomp -lm

./a.out
