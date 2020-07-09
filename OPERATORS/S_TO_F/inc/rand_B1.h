#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "q_macros.h"
#include "rand_struct.h"
//START_FOR_CDEF
extern int
rand_B1(
  uint64_t *X,
  uint64_t nX,
  RAND_B1_REC_TYPE *ptr_in,
  uint64_t idx
  );
//STOP_FOR_CDEF
