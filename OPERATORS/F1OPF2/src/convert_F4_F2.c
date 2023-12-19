#include "q_incs.h"
#include "qtypes.h"
#include "convert_F4_F2.h"

int
convert_F4_F2(
    float *X,
    uint32_t nX,
    bfloat16 *Y
    )
{
  int status = 0;
  for ( uint32_t i = 0; i < nX; i++ ) { 
    Y[i] = F4_to_F2(X[i]);
  }
BYE:
  return status;
}
