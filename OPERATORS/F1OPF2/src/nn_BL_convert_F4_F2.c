#include "q_incs.h"
#include "qtypes.h"
#include "nn_BL_convert_F4_F2.h"

int
nn_BL_convert_F4_F2(
    float *X,
    bool *nn_X,
    uint32_t nX,
    bfloat16 *Y,
    bool *nn_Y
    )
{
  int status = 0;
  if ( nn_X == NULL ) { if ( nn_Y != NULL ) { go_BYE(-1); } } 
  if ( nn_X != NULL ) { if ( nn_Y == NULL ) { go_BYE(-1); } } 
  if ( nn_X == NULL ) { 
#pragma omp parallel for schedule(static, 1024)
    for ( uint32_t i = 0; i < nX; i++ ) { 
      Y[i] = F4_to_F2(X[i]);
    }
  }
  else {
#pragma omp parallel for schedule(static, 1024)
    for ( uint32_t i = 0; i < nX; i++ ) { 
      nn_Y[i] = nn_X[i];
      if ( nn_X[i] == false ) {
        Y[i] = 0;
      }
      else { 
        Y[i] = F4_to_F2(X[i]);
      }
    }
  }
BYE:
  return status;
}
