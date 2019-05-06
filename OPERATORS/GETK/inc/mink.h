#include "q_incs.h"

typedef struct _reduce_mink_args {
    int32_t *val; // [k] 
    int32_t *drag; // [k] 
    int32_t n; // actual occupancy
    int32_t k; // max occupancy
  } REDUCE_mink_ARGS;

extern int
mink(
   const int32_t * restrict val, // distance vector [n] 
   uint64_t n, // size of distance vector
   const int32_t * restrict drag, // goal vector [n]
   void *ptr_in_args // structure maintaining k min distances and respective goals
   );
