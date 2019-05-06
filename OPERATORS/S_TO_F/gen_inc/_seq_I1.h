
#include "q_macros.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

// Below structure needs to be same as structure template in seq_mem_initialize.lua
typedef struct _seq_I1_rec_type {
   int8_t start;
   int8_t by;
} SEQ_I1_REC_TYPE;

extern int
seq_I1(
  int8_t *X,
  uint64_t nX,
  SEQ_I1_REC_TYPE *ptr_in,
  uint64_t idx
  );
   
