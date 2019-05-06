
#include "q_incs.h"
#include <unistd.h>
#include <stdint.h>
#include <stdbool.h>

typedef struct _reduce_sum_sqr_I1_args {
  uint64_t sum_sqr_val;
  uint64_t num; // number of non-null elements inspected
  } REDUCE_sum_sqr_I1_ARGS;
  
extern int
sum_sqr_I1(  
      const int8_t * restrict in,  
      uint64_t nR,
      void *ptr_args,
      uint64_t idx
      ) 
;

   
