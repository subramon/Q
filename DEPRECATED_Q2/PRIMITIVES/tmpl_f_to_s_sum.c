#include <inttypes.h>
#include "f_to_s_sum___XTYPE__.h"

//<hdr>
void
f_to_s_sum___XTYPE__(
    __ITYPE__ *X,
    uint64_t nR,
    __OTYPE__ *ptr_rslt // should be initialized prior to coming here
    )
//</hdr>
{
  *ptr_rslt = 0;
  for ( uint64_t i = 0; i < nR; i++ ) { 
    *ptr_rslt += X[i];
  }
}
