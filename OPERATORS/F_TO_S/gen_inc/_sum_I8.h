
#include "q_incs.h"
#include <unistd.h>
#include <stdint.h>
#include <stdbool.h>

typedef struct _reduce_sum_I8_args {
  int64_t sum_val;
  uint64_t num; // number of non-null elements inspected
  } REDUCE_sum_I8_ARGS;
  
extern int
sum_I8(  
      const int64_t * restrict in,  
      uint64_t nR,
      void *ptr_args,
      uint64_t idx
      ) 
;

   
