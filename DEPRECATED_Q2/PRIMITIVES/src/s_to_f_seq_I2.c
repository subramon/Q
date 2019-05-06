#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "s_to_f_seq_I2.h"

void
s_to_f_seq_I2(
    int16_t *X,
    const long long nX,
    const int16_t start,
    const int16_t incr
    )

{
  int16_t val = start;
  for ( long long i = 0; i < nX; i++ ) {
    X[i] = val;
    val += incr;
  }
}
