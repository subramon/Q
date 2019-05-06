
#include "q_incs.h"

typedef struct _reduce_min_F8_args {
  double min_val;
  uint64_t num; // number of non-null elements inspected
  int64_t min_index; // storing min value index (signed integer)
  } REDUCE_min_F8_ARGS;
  
extern int
min_F8(  
      const double * restrict in,  
      uint64_t nR,
      void *ptr_args,
      uint64_t idx
      ) 
;

   
