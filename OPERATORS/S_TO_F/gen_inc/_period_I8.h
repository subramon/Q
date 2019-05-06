
#include "q_macros.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

// Below structure needs to be same as structure template in period_mem_initialize.lua
typedef struct _period_I8_rec_type {
   int64_t start;
   int64_t by;
   int period;
} PERIOD_I8_REC_TYPE;

extern int
period_I8(
  int64_t *X,
  uint64_t nX,
  PERIOD_I8_REC_TYPE *ptr_in,
  uint64_t idx
  );
   
