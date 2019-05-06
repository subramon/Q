
#include "q_macros.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

// Below structure needs to be same as structure template in seq_mem_initialize.lua
typedef struct _seq_F8_rec_type {
   double start;
   double by;
} SEQ_F8_REC_TYPE;

extern int
seq_F8(
  double *X,
  uint64_t nX,
  SEQ_F8_REC_TYPE *ptr_in,
  uint64_t idx
  );
   
