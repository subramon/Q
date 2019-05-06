
#include "q_macros.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

// Below structure needs to be same as structure template in period_mem_initialize.lua
typedef struct _period_I2_rec_type {
   int16_t start;
   int16_t by;
   int period;
} PERIOD_I2_REC_TYPE;

extern int
period_I2(
  int16_t *X,
  uint64_t nX,
  PERIOD_I2_REC_TYPE *ptr_in,
  uint64_t idx
  );
   
