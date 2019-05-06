
#include "q_macros.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

// Below structure needs to be same as structure template in period_mem_initialize.lua
typedef struct _period_I1_rec_type {
   int8_t start;
   int8_t by;
   int period;
} PERIOD_I1_REC_TYPE;

extern int
period_I1(
  int8_t *X,
  uint64_t nX,
  PERIOD_I1_REC_TYPE *ptr_in,
  uint64_t idx
  );
   
