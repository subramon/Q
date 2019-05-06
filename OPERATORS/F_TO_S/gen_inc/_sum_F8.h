
#include "q_incs.h"
#include <unistd.h>
#include <stdint.h>
#include <stdbool.h>

typedef struct _reduce_sum_F8_args {
  double sum_val;
  uint64_t num; // number of non-null elements inspected
  } REDUCE_sum_F8_ARGS;
  
extern int
sum_F8(  
      const double * restrict in,  
      uint64_t nR,
      void *ptr_args,
      uint64_t idx
      ) 
;

   
