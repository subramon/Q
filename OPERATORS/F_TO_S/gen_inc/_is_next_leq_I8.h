
#include "q_incs.h"

typedef struct _is_next_leq_I8_ARGS  {
  int64_t prev_val; 
  int is_violation;
  int64_t num_seen;
} is_next_leq_I8_ARGS;

extern int
is_next_leq_I8(  
      const int64_t * restrict in,  
      uint64_t nR,
      is_next_leq_I8_ARGS *ptr_args,
      uint64_t idx // not used for now
      ) 
;

   
