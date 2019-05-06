
#include "q_macros.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

// Below structure needs to be same as structure template in seq_mem_initialize.lua
typedef struct _seq_I2_rec_type {
   int16_t start;
   int16_t by;
} SEQ_I2_REC_TYPE;

extern int
seq_I2(
  int16_t *X,
  uint64_t nX,
  SEQ_I2_REC_TYPE *ptr_in,
  uint64_t idx
  );
   
