#include <inttypes.h>
#include "f_to_s_sum_F4.h"


void
f_to_s_sum_F4(
    float *X,
    uint64_t nR,
    double *ptr_rslt // should be initialized prior to coming here
    )

{
  *ptr_rslt = 0;
  for ( uint64_t i = 0; i < nR; i++ ) { 
    *ptr_rslt += X[i];
  }
}
