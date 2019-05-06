
#include "q_incs.h"

typedef struct _reduce_max_F4_args {
  float max_val;
  uint64_t num; // number of non-null elements inspected
  int64_t max_index; // storing min value index (signed integer)
  } REDUCE_max_F4_ARGS;
  
extern int
max_F4(  
      const float * restrict in,  
      uint64_t nR,
      void *ptr_args,
      uint64_t idx
      ) 
;

   
