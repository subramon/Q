
#include "q_macros.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

// Below structure needs to be same as structure template in period_mem_initialize.lua
typedef struct _period_I4_rec_type {
   int32_t start;
   int32_t by;
   int period;
} PERIOD_I4_REC_TYPE;

extern int
period_I4(
  int32_t *X,
  uint64_t nX,
  PERIOD_I4_REC_TYPE *ptr_in,
  uint64_t idx
  );
   
