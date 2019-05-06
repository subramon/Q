
#include "q_incs.h"

typedef struct _is_next_neq_F4_ARGS  {
  float prev_val; 
  int is_violation;
  int64_t num_seen;
} is_next_neq_F4_ARGS;

extern int
is_next_neq_F4(  
      const float * restrict in,  
      uint64_t nR,
      is_next_neq_F4_ARGS *ptr_args,
      uint64_t idx // not used for now
      ) 
;

   
