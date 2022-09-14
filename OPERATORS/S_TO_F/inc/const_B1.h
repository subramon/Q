#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "q_macros.h"
#include "const_struct.h"
//START_FOR_CDEF
extern int
const_B1(
  uint64_t *X,
  uint64_t nX,
  CONST_B1_REC_TYPE *ptr_arg,
  uint64_t lb // not used but for consistency with others
  );
//STOP_FOR_CDEF
