#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "s_to_f_period_I2.h"

void
s_to_f_period_I2(
    int16_t *X,
    const uint64_t nX,
    const int16_t start,
    const int16_t incr,
    const uint64_t period
    )

{
  int16_t val = start;
  uint64_t counter = 0;
  for ( uint64_t i = 0; i < nX; i++ ) {
    X[i] = val;
    val += incr;
    counter++;
    if ( counter == period ) { val = start; }
  }
}
