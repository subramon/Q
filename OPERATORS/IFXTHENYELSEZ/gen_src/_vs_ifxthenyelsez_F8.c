
#include "_vs_ifxthenyelsez_F8.h"

int
vs_ifxthenyelsez_F8(  
      uint64_t * restrict const x, // condition field 
      double * restrict const y, // input field 1
      const double * const ptr_sval_z, // scalar val
      double * restrict const w, // output field
      uint64_t n
      )
{
  int status = 0;
  if ( n == 0 ) { go_BYE(-1); }
  if ( x == NULL ) { go_BYE(-1); }
  if ( y == NULL ) { go_BYE(-1); }
  if ( ptr_sval_z == NULL ) { go_BYE(-1); }
  if ( w == NULL ) { go_BYE(-1); }
  double sval_z = *ptr_sval_z;

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
   
