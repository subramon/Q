
#include "_sv_ifxthenyelsez_I4.h"

int
sv_ifxthenyelsez_I4(  
      const uint64_t * restrict const x, // condition field 
      const int32_t * const ptr_sval_y, // scalar val
      const int32_t * restrict const z, // input field 1
      int32_t * restrict const w, // output field
      uint64_t n
      )
{
  int status = 0;
  if ( n == 0 ) { go_BYE(-1); }
  if ( x == NULL ) { go_BYE(-1); }
  if ( ptr_sval_y == NULL ) { go_BYE(-1); }
  if ( z == NULL ) { go_BYE(-1); }
  if ( w == NULL ) { go_BYE(-1); }
  int32_t sval_y = *ptr_sval_y;

#pragma omp parallel for schedule(static, 256)
  for ( uint64_t i = 0; i < n; i++ ) { 
    
    uint64_t widx = i >> 6; // word index
    uint64_t bidx = i & 0x3F; // bit index
    uint32_t rslt = (x[widx] >> bidx) & 0x1;
    if ( rslt == 1 ) { 
      w[i] = sval_y;
    }
    else {
      w[i] = z[i];
    }
  }
BYE:
  return status;
}
   
