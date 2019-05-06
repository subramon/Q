#include "q_incs.h"


int
bin(
    const int * const restrict X,
    uint64_t nX,
    const int * const restrict Y,
    int nY
    int8_t * restrict Z /* [nX] */
   )
{
  int status = 0;
  if ( nY >= 128 ) { go_BYE(-1); }

#pragma omp parallel for schedule(static, 1024)
  for ( uint64_t i = 0; i < nX; i++ ) { 
    int x_i = X[i];
    Z[i] = 0;
    for ( int i = n-1; i >= 0; i-- ) { 
      if ( x_i >= Y[i] ) {
        Z[i] = i+1;
        break;
      }
    }
  }
      
BYE:
  return status;
}
  
