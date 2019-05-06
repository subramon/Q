#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "s_to_f_seq_I8.h"

void
s_to_f_seq_I8(
    int64_t *X,
    const long long nX,
    const int64_t start,
    const int64_t incr
    )

{
  int64_t val = start;
  for ( long long i = 0; i < nX; i++ ) {
    X[i] = val;
    val += incr;
  }
}
