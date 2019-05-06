#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "s_to_f_const___XTYPE__.h"
//<hdr>
void
s_to_f_const___XTYPE__(
    __TYPE__ *X,
    uint64_t nX,
    __TYPE__ val
    )
//</hdr>
{
  for ( uint64_t i = 0; i < nX; i++ ) {
    X[i] = val;
  }
}
