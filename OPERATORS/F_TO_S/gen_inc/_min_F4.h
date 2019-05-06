
#include "q_incs.h"

typedef struct _reduce_min_F4_args {
  float min_val;
  uint64_t num; // number of non-null elements inspected
  int64_t min_index; // storing min value index (signed integer)
  } REDUCE_min_F4_ARGS;
  
extern int
min_F4(  
      const float * restrict in,  
      uint64_t nR,
      void *ptr_args,
      uint64_t idx
      ) 
;

   
