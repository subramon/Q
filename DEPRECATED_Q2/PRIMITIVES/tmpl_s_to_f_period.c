#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "s_to_f_period___XTYPE__.h"
//<hdr>
void
s_to_f_period___XTYPE__(
    __TYPE__ *X,
    const uint64_t nX,
    const __TYPE__ start,
    const __TYPE__ incr,
    const uint64_t period
    )
//</hdr>
{
  __TYPE__ val = start;
  uint64_t counter = 0;
  for ( uint64_t i = 0; i < nX; i++ ) {
    X[i] = val;
    val += incr;
    counter++;
    if ( counter == period ) { val = start; }
  }
}
