
#include "q_macros.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

// Below structure needs to be same as structure template in seq_mem_initialize.lua
typedef struct _seq_I8_rec_type {
   int64_t start;
   int64_t by;
} SEQ_I8_REC_TYPE;

extern int
seq_I8(
  int64_t *X,
  uint64_t nX,
  SEQ_I8_REC_TYPE *ptr_in,
  uint64_t idx
  );
   
