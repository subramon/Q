#include <inttypes.h>
#include "f_to_s_min_I2.h"


void
f_to_s_min_I2(
    int16_t *X,
    uint64_t nR,
    int16_t *ptr_rslt // should be initialized prior to coming here
    )

{
  *ptr_rslt = X[0];
  for ( uint64_t i = 1; i < nR; i++ ) { 
    if ( X[i] < *ptr_rslt ) {
      *ptr_rslt = X[i];
    }
  }
}
