
#include "q_incs.h"

typedef struct _reduce_max_I4_args {
  int32_t max_val;
  uint64_t num; // number of non-null elements inspected
  int64_t max_index; // storing min value index (signed integer)
  } REDUCE_max_I4_ARGS;
  
extern int
max_I4(  
      const int32_t * restrict in,  
      uint64_t nR,
      void *ptr_args,
      uint64_t idx
      ) 
;

   
