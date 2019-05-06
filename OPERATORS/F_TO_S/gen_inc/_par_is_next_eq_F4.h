
#include "q_incs.h"

typedef struct _par_is_next_eq_F4_ARGS  {
  float prev_val; 
  int is_violation;
  int64_t num_seen;
} par_is_next_eq_F4_ARGS;

extern int
par_is_next_eq_F4(  
      const float * restrict in,  
      uint64_t nR,
      par_is_next_eq_F4_ARGS *ptr_args,
      uint64_t idx // not used for now
      ) 
;

   
