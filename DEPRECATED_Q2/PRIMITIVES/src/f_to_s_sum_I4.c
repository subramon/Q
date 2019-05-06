#include <inttypes.h>
#include "f_to_s_sum_I4.h"


void
f_to_s_sum_I4(
    int32_t *X,
    uint64_t nR,
    int64_t *ptr_rslt // should be initialized prior to coming here
    )

{
  *ptr_rslt = 0;
  for ( uint64_t i = 0; i < nR; i++ ) { 
    *ptr_rslt += X[i];
  }
}
