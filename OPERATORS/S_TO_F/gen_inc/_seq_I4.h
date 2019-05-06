
#include "q_macros.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

// Below structure needs to be same as structure template in seq_mem_initialize.lua
typedef struct _seq_I4_rec_type {
   int32_t start;
   int32_t by;
} SEQ_I4_REC_TYPE;

extern int
seq_I4(
  int32_t *X,
  uint64_t nX,
  SEQ_I4_REC_TYPE *ptr_in,
  uint64_t idx
  );
   
