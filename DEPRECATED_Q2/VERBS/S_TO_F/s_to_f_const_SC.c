#include <stdio.h>
#include "q_constants.h"
#include "qtypes.h"
#include "macros.h"
#include "s_to_f_const_SC.h"
void
s_to_f_const_SC(
    char *X, 
    uint64_t nR, 
    int fldlen, 
    const char *val
    )
{
  int status = 0;
  for ( uint64_t i = 0; i < nR; i++ ) {
    memcpy(X, val, fldlen);
    X += fldlen;
  }
}
