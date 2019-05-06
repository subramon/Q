#include <inttypes.h>
#include "f_to_s___CMPTXT_____XTYPE__.h"

//<hdr>
void
f_to_s___CMPTXT_____XTYPE__(
    __ITYPE__ *X,
    uint64_t nR,
    __ITYPE__ *ptr_rslt // should be initialized prior to coming here
    )
//</hdr>
{
  *ptr_rslt = X[0];
  for ( uint64_t i = 1; i < nR; i++ ) { 
    if ( X[i] __CMPOP__ *ptr_rslt ) {
      *ptr_rslt = X[i];
    }
  }
}
