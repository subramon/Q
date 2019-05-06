
#include "q_macros.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

// Below structure needs to be same as structure template in period_mem_initialize.lua
typedef struct _period_F8_rec_type {
   double start;
   double by;
   int period;
} PERIOD_F8_REC_TYPE;

extern int
period_F8(
  double *X,
  uint64_t nX,
  PERIOD_F8_REC_TYPE *ptr_in,
  uint64_t idx
  );
   
