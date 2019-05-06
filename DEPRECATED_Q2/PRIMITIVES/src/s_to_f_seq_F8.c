#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "s_to_f_seq_F8.h"

void
s_to_f_seq_F8(
    double *X,
    const long long nX,
    const double start,
    const double incr
    )

{
  double val = start;
  for ( long long i = 0; i < nX; i++ ) {
    X[i] = val;
    val += incr;
  }
}
