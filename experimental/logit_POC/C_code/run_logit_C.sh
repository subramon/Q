#!/bin/bash

gcc -O4 -fopenmp $QC_FLAGS $Q_SRC_ROOT/experimental/logit_POC/C_code/test_logit_C.c \
  $Q_SRC_ROOT/experimental/logit_POC/C_code/logit_I8.c \
  $Q_SRC_ROOT/UTILS/src/rdtsc.c \
  -I$Q_SRC_ROOT/experimental/logit_POC/C_code/ \
  -I$Q_SRC_ROOT/UTILS/inc/ \
  -I$Q_SRC_ROOT/UTILS/gen_inc/ -lgomp -lm

./a.out
