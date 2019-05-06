#include <inttypes.h>
#include <stdint.h>
#include <unistd.h>
#include <strings.h>
#include "q_macros.h"

#ifndef __SUM_B1
#define __SUM_B1
typedef struct _reduce_sum_B1_args {
  uint64_t  sum_val;
  uint64_t num; // number of non-null elements inspected } REDUCE_sum_B1_ARGS;
  } REDUCE_sum_B1_ARGS;
extern unsigned int 
popcount64(
    uint64_t value
    );
extern int
sum_B1(  
      const uint64_t  * restrict in,  
      uint64_t nR,
      REDUCE_sum_B1_ARGS *in_ptr_args,
      uint64_t idx
      );
#endif
