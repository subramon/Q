#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "s_to_f_const_F4.h"

void
s_to_f_const_F4(
    float *X,
    uint64_t nX,
    float val
    )

{
  for ( uint64_t i = 0; i < nX; i++ ) {
    X[i] = val;
  }
}
