
#include "q_incs.h"

typedef struct _par_is_next_eq_I8_ARGS  {
  int64_t prev_val; 
  int is_violation;
  int64_t num_seen;
} par_is_next_eq_I8_ARGS;

extern int
par_is_next_eq_I8(  
      const int64_t * restrict in,  
      uint64_t nR,
      par_is_next_eq_I8_ARGS *ptr_args,
      uint64_t idx // not used for now
      ) 
;

   
