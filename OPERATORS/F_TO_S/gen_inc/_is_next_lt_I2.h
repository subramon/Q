
#include "q_incs.h"

typedef struct _is_next_lt_I2_ARGS  {
  int16_t prev_val; 
  int is_violation;
  int64_t num_seen;
} is_next_lt_I2_ARGS;

extern int
is_next_lt_I2(  
      const int16_t * restrict in,  
      uint64_t nR,
      is_next_lt_I2_ARGS *ptr_args,
      uint64_t idx // not used for now
      ) 
;

   
