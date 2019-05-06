
#include "q_incs.h"

typedef struct _reduce_max_F8_args {
  double max_val;
  uint64_t num; // number of non-null elements inspected
  int64_t max_index; // storing min value index (signed integer)
  } REDUCE_max_F8_ARGS;
  
extern int
max_F8(  
      const double * restrict in,  
      uint64_t nR,
      void *ptr_args,
      uint64_t idx
      ) 
;

   
