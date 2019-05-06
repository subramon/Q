
#include "q_incs.h"

typedef struct _is_next_geq_F8_ARGS  {
  double prev_val; 
  int is_violation;
  int64_t num_seen;
} is_next_geq_F8_ARGS;

extern int
is_next_geq_F8(  
      const double * restrict in,  
      uint64_t nR,
      is_next_geq_F8_ARGS *ptr_args,
      uint64_t idx // not used for now
      ) 
;

   
