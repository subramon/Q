
#include "q_macros.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

// Below structure needs to be same as structure template in seq_mem_initialize.lua
typedef struct _seq_F4_rec_type {
   float start;
   float by;
} SEQ_F4_REC_TYPE;

extern int
seq_F4(
  float *X,
  uint64_t nX,
  SEQ_F4_REC_TYPE *ptr_in,
  uint64_t idx
  );
   
