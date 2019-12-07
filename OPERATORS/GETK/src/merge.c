#include "q_incs.h"

int merge_min(
    int32_t *X, /* [nX] */
    uint32_t nX,
    int32_t *Y, /* [nY] */
    uint32_t nY,
    int32_t *Z, /* [nZ] */
    uint32_t nZ,
    uint32_t *ptr_num_in_Z
    )
{
  int status = 0;
  int xidx = 0, yidx = 0, zidx = 0;

  // Basic checks on parameters
  if ( ( X == NULL ) && ( nX > 0 ) ) { go_BYE(-1); }
  if ( ( Y == NULL ) && ( nY > 0 ) ) { go_BYE(-1); }
  if ( ( Z == NULL ) || ( nZ == 0 ) ) { go_BYE(-1); }
  //-----------------------------------
  for ( ; zidx < nZ; ) {
    if ( xidx >= nX ) {
      // copy whatever is needed from Y
      for ( ; (( yidx < nY ) && ( zidx < nZ )); ) { 
        Z[zidx++] = Y[yidx++];
      }
      break;
    }
    if ( yidx >= nY ) {
      // copy whatever is needed from X
      for ( ; (( xidx < nX ) && ( zidx < nZ )); ) { 
        Z[zidx++] = X[xidx++];
      }
      break;
    }
    if ( Y[yidx] < X[xidx] ) { 
      Z[zidx] = Y[yidx];
      yidx++;
    }
    else  {
      Z[zidx] = X[xidx];
      xidx++;
    }
    zidx++;
  }
  *ptr_num_in_Z = zidx;
BYE:
  return status;
}
