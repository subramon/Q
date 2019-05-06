
#include "_simple_ainb_F4_F8.h"

int
simple_ainb_F4_F8(  
      const float * restrict A,  
      uint64_t nA,
      const double * restrict B,  
      uint16_t nB,
      uint64_t *C // nA bytes
      )
{
  int status = 0;
  if ( nB >= 32 ) { go_BYE(-1); }

  uint8_t *lC = (uint8_t *)C;
#pragma omp parallel for schedule(static, 256)
  for ( uint64_t i = 0; i < nA; i++ ) { 
    lC[i] = 0; 
  }
#pragma omp parallel for schedule(static, 256)
  for ( uint64_t i = 0; i < nA; i++ ) { 
    uint16_t rslt = 0;
    for ( uint16_t j = 0; j < nB; j++ ) { 
      rslt += (A[i] == B[j]);
    }
    if ( rslt > 0 ) {
      set_bit_u64(C, i, 1);
   }
  }
BYE:
  return status;
}
   
