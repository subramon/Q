
#include "q_incs.h"
#include <unistd.h>
#include <stdint.h>
#include <stdbool.h>

typedef struct _reduce_sum_sqr_F4_args {
  double sum_sqr_val;
  uint64_t num; // number of non-null elements inspected
  } REDUCE_sum_sqr_F4_ARGS;
  
extern int
sum_sqr_F4(  
      const float * restrict in,  
      uint64_t nR,
      void *ptr_args,
      uint64_t idx
      ) 
;

   
