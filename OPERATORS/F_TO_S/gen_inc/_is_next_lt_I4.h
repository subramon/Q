
#include "q_incs.h"

typedef struct _is_next_lt_I4_ARGS  {
  int32_t prev_val; 
  int is_violation;
  int64_t num_seen;
} is_next_lt_I4_ARGS;

extern int
is_next_lt_I4(  
      const int32_t * restrict in,  
      uint64_t nR,
      is_next_lt_I4_ARGS *ptr_args,
      uint64_t idx // not used for now
      ) 
;

   
