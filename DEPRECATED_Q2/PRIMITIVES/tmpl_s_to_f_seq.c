#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "s_to_f_seq___XTYPE__.h"
//<hdr>
void
s_to_f_seq___XTYPE__(
    __TYPE__ *X,
    const long long nX,
    const __TYPE__ start,
    const __TYPE__ incr
    )
//</hdr>
{
  __TYPE__ val = start;
  for ( long long i = 0; i < nX; i++ ) {
    X[i] = val;
    val += incr;
  }
}
