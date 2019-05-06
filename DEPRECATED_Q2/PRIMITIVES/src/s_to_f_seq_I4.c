#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "s_to_f_seq_I4.h"

void
s_to_f_seq_I4(
    int32_t *X,
    const long long nX,
    const int32_t start,
    const int32_t incr
    )

{
  int32_t val = start;
  for ( long long i = 0; i < nX; i++ ) {
    X[i] = val;
    val += incr;
  }
}
