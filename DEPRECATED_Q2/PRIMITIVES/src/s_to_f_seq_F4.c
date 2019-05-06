#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "s_to_f_seq_F4.h"

void
s_to_f_seq_F4(
    float *X,
    const long long nX,
    const float start,
    const float incr
    )

{
  float val = start;
  for ( long long i = 0; i < nX; i++ ) {
    X[i] = val;
    val += incr;
  }
}
