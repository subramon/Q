#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "s_to_f_const_I2.h"

void
s_to_f_const_I2(
    int16_t *X,
    uint64_t nX,
    int16_t val
    )

{
  for ( uint64_t i = 0; i < nX; i++ ) {
    X[i] = val;
  }
}
