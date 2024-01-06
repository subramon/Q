#include "q_incs.h"
#include "qtypes.h"
#include "convert_F2_F4.h"

int
convert_F2_F4(
    bfloat16 *X,
    uint32_t nX,
    float *Y
    )
{
  int status = 0;
#pragma omp parallel for schedule(static, 1024)
  for ( uint32_t i = 0; i < nX; i++ ) { 
    Y[i] = F2_to_F4(X[i]);
  }
BYE:
  return status;
}
