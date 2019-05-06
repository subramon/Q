#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "s_to_f_seq_I1.h"

void
s_to_f_seq_I1(
    int8_t *X,
    const long long nX,
    const int8_t start,
    const int8_t incr
    )

{
  int8_t val = start;
  for ( long long i = 0; i < nX; i++ ) {
    X[i] = val;
    val += incr;
  }
}
