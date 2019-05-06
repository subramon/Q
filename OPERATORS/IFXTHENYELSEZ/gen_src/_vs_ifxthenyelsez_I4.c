
#include "_vs_ifxthenyelsez_I4.h"

int
vs_ifxthenyelsez_I4(  
      uint64_t * restrict const x, // condition field 
      int32_t * restrict const y, // input field 1
      const int32_t * const ptr_sval_z, // scalar val
      int32_t * restrict const w, // output field
      uint64_t n
      )
{
  int status = 0;
  if ( n == 0 ) { go_BYE(-1); }
  if ( x == NULL ) { go_BYE(-1); }
  if ( y == NULL ) { go_BYE(-1); }
  if ( ptr_sval_z == NULL ) { go_BYE(-1); }
  if ( w == NULL ) { go_BYE(-1); }
  int32_t sval_z = *ptr_sval_z;

#pragma omp parallel for schedule(static, 256)
  for ( uint64_t i = 0; i < n; i++ ) { 
    
    uint64_t widx = i >> 6; // word index
    uint64_t bidx = i & 0x3F; // bit index
    uint32_t rslt = (x[widx] >> bidx) & 0x1;
    if ( rslt == 1 ) { 
      w[i] = y[i];
    }
    else {
      w[i] = sval_z;
    }
  }
BYE:
  return status;
}
   
