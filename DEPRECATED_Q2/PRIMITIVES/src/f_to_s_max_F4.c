#include <inttypes.h>
#include "f_to_s_max_F4.h"


void
f_to_s_max_F4(
    float *X,
    uint64_t nR,
    float *ptr_rslt // should be initialized prior to coming here
    )

{
  *ptr_rslt = X[0];
  for ( uint64_t i = 1; i < nR; i++ ) { 
    if ( X[i] > *ptr_rslt ) {
      *ptr_rslt = X[i];
    }
  }
}
