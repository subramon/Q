#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "s_to_f_const_F8.h"

void
s_to_f_const_F8(
    double *X,
    uint64_t nX,
    double val
    )

{
  for ( uint64_t i = 0; i < nX; i++ ) {
    X[i] = val;
  }
}
